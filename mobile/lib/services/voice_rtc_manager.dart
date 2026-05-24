import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'auth_config.dart';

/// WebRTC ses — socket sinyal relay.
class VoiceRtcManager {
  VoiceRtcManager({required this.socket, required this.myUserId});

  final io.Socket socket;
  final String myUserId;

  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, MediaStream> _remoteStreams = {};
  MediaStream? _localStream;
  bool _active = false;
  bool _micMuted = false;

  static Map<String, dynamic> get _rtcConfig => {
        'iceServers': AuthConfig.iceServers,
        'sdpSemantics': 'unified-plan',
      };

  bool _shouldOfferTo(String peerId) => myUserId.compareTo(peerId) < 0;

  Future<void> _configureAudioSession() async {
    if (kIsWeb) return;
    try {
      await Helper.setAndroidAudioConfiguration(
        AndroidAudioConfiguration.communication,
      );
      await Helper.setSpeakerphoneOn(true);
    } catch (e) {
      if (kDebugMode) debugPrint('voice: audio session $e');
    }
  }

  Future<void> start() async {
    if (_active) return;
    _active = true;

    await _configureAudioSession();

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });

    socket.on('voice:signal', _onSignal);
    socket.on('voice:peer-joined', _onPeerJoined);
    socket.on('voice:peer-left', _onPeerLeft);
  }

  Future<void> stop() async {
    _active = false;
    socket.off('voice:signal');
    socket.off('voice:peer-joined');
    socket.off('voice:peer-left');

    for (final pc in _peers.values) {
      await pc.close();
    }
    _peers.clear();
    _remoteStreams.clear();

    await _localStream?.dispose();
    _localStream = null;
    _micMuted = false;
  }

  bool get isMicMuted => _micMuted;

  Future<void> setMicrophoneMuted(bool muted) async {
    _micMuted = muted;
    final stream = _localStream;
    if (stream == null) return;
    for (final track in stream.getAudioTracks()) {
      track.enabled = !muted;
    }
  }

  void handlePeersList(List<dynamic> peers) {
    for (final id in peers) {
      final peerId = id.toString();
      if (peerId != myUserId) {
        unawaited(_connectToPeer(peerId, createOffer: _shouldOfferTo(peerId)));
      }
    }
  }

  Future<void> _onPeerJoined(dynamic data) async {
    if (data is! Map) return;
    final peerId = data['userId'] as String?;
    if (peerId == null || peerId == myUserId) return;
    await _connectToPeer(peerId, createOffer: _shouldOfferTo(peerId));
  }

  Future<void> _onPeerLeft(dynamic data) async {
    if (data is! Map) return;
    final peerId = data['userId'] as String?;
    if (peerId == null) return;
    final pc = _peers.remove(peerId);
    await pc?.close();
    _remoteStreams.remove(peerId);
  }

  Future<void> _onSignal(dynamic data) async {
    if (data is! Map) return;
    final from = data['from'] as String?;
    if (from == null || from == myUserId) return;

    final type = data['type'] as String?;
    if (type == 'offer') {
      final pc = await _getOrCreatePeer(from);
      await pc.setRemoteDescription(
        RTCSessionDescription(data['sdp'] as String, 'offer'),
      );
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      _emitSignal(to: from, type: 'answer', sdp: answer.sdp);
    } else if (type == 'answer') {
      final pc = _peers[from];
      if (pc != null) {
        await pc.setRemoteDescription(
          RTCSessionDescription(data['sdp'] as String, 'answer'),
        );
      }
    } else if (type == 'candidate') {
      final pc = _peers[from];
      final c = data['candidate'] as Map?;
      if (pc != null && c != null) {
        await pc.addCandidate(
          RTCIceCandidate(
            c['candidate'] as String?,
            c['sdpMid'] as String?,
            c['sdpMLineIndex'] as int?,
          ),
        );
      }
    }
  }

  Future<void> _connectToPeer(String peerId, {required bool createOffer}) async {
    if (_peers.containsKey(peerId)) return;
    final pc = await _getOrCreatePeer(peerId);
    if (createOffer) {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      _emitSignal(to: peerId, type: 'offer', sdp: offer.sdp);
    }
  }

  Future<void> _playRemoteAudio(String peerId, MediaStream stream) async {
    _remoteStreams[peerId] = stream;
    for (final track in stream.getAudioTracks()) {
      track.enabled = true;
      try {
        await Helper.setVolume(1.0, track);
      } catch (_) {}
    }
    await Helper.setSpeakerphoneOn(true);
  }

  Future<RTCPeerConnection> _getOrCreatePeer(String peerId) async {
    if (_peers.containsKey(peerId)) return _peers[peerId]!;

    final pc = await createPeerConnection(_rtcConfig);
    _peers[peerId] = pc;

    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await pc.addTrack(track, _localStream!);
      }
    }

    pc.onIceCandidate = (c) {
      if (c.candidate != null && c.candidate!.isNotEmpty) {
        _emitSignal(
          to: peerId,
          type: 'candidate',
          candidate: {
            'candidate': c.candidate,
            'sdpMid': c.sdpMid,
            'sdpMLineIndex': c.sdpMLineIndex,
          },
        );
      }
    };

    pc.onTrack = (event) async {
      if (event.track.kind == 'audio') {
        event.track.enabled = true;
        if (event.streams.isNotEmpty) {
          await _playRemoteAudio(peerId, event.streams[0]);
        }
      }
      if (kDebugMode) {
        debugPrint('voice: remote audio from $peerId');
      }
    };

    return pc;
  }

  void _emitSignal({
    required String to,
    required String type,
    String? sdp,
    Map<String, dynamic>? candidate,
  }) {
    socket.emit('voice:signal', {
      'to': to,
      'type': type,
      if (sdp != null) 'sdp': sdp,
      if (candidate != null) 'candidate': candidate,
    });
  }
}
