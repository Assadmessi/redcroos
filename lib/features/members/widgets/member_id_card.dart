import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../data/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';

class MemberIdCard extends StatefulWidget {
  final Member member;
  final String issuerNameEn;
  final DateTime issuedDate;

  const MemberIdCard({
    super.key,
    required this.member,
    required this.issuerNameEn,
    required this.issuedDate,
  });

  @override
  State<MemberIdCard> createState() => _MemberIdCardState();
}

class _MemberIdCardState extends State<MemberIdCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showingFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showingFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showingFront = !_showingFront);
  }

  DateTime get _expiryDate =>
      DateTime(widget.issuedDate.year + 1, widget.issuedDate.month, widget.issuedDate.day);

  void _openFullscreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: _FullscreenIdCard(
            member: widget.member,
            issuerNameEn: widget.issuerNameEn,
            issuedDate: widget.issuedDate,
            expiryDate: _expiryDate,
            startOnFront: _showingFront,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _flip,
          onLongPress: _openFullscreen,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * math.pi;
              final isFlipped = angle > math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: isFlipped
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _CardBack(
                          member: widget.member,
                          issuerNameEn: widget.issuerNameEn,
                          issuedDate: widget.issuedDate,
                          expiryDate: _expiryDate,
                        ),
                      )
                    : _CardFront(member: widget.member),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _flip,
              icon: const Icon(Icons.flip, size: 18),
              label: Text(_showingFront ? 'Tap to flip' : 'Tap to flip back'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _openFullscreen,
              icon: const Icon(Icons.fullscreen, size: 18),
              label: const Text('View fullscreen'),
            ),
          ],
        ),
      ],
    );
  }
}

const _cardWidth = 340.0;
const _cardHeight = 248.0; // increased from 215 — back face content (icon,
                            // name, NRC, DOB, address x2 lines, blood/issued/
                            // expiry x3 lines, issuer x2 lines) needs more
                            // room than the original CR80-ratio estimate

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      height: _cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Watermark background
            Positioned.fill(child: _Watermark()),
            child,
          ],
        ),
      ),
    );
  }
}

class _Watermark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Opacity(
        opacity: 0.06,
        child: Transform.rotate(
          angle: -0.4,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              40,
              (i) => const Text(
                'MYANMAR RED CROSS BRIGADE BOTAHTAUNG',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final Member member;
  const _CardFront({required this.member});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Text(
              'MYANMAR RED CROSS BRIGADE',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 2),
            const Text(
              'Botahtaung Township',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10),
            ),
            const Text(
              'Eastern Yangon District, Yangon Region',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 70,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AvatarColorGen.fromString(member.id),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: member.photoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(member.photoUrl!, fit: BoxFit.cover),
                                )
                              : Center(
                                  child: Text(
                                    member.initials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: -6,
                          right: -10,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Color(0xFFD32F2F), size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              member.nameEn.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              member.rankNameEn,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              'BTHG-${member.companyNo ?? "HQ"}/YGN',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Colors.black54),
            ),
            if (member.companyNo != null && member.platoonNo != null)
              Text(
                'COMPANY (${member.companyNo}) PLATOON (${member.platoonNo})',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final Member member;
  final String issuerNameEn;
  final DateTime issuedDate;
  final DateTime expiryDate;

  const _CardBack({
    required this.member,
    required this.issuerNameEn,
    required this.issuedDate,
    required this.expiryDate,
  });

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD32F2F), width: 2),
              ),
              child: const Icon(Icons.add, color: Color(0xFFD32F2F), size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              member.nameEn.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            if (member.nrc != null)
              Text(member.nrc!, style: const TextStyle(fontSize: 10)),
            Text(_fmt(member.dateOfBirth), style: const TextStyle(fontSize: 10)),
            const SizedBox(height: 3),
            Text(
              member.address,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: Colors.black54),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Blood Type  : ${member.bloodTypeDisplay}',
                      style: const TextStyle(fontSize: 9)),
                  Text('Issued Date : ${_fmt(issuedDate)}',
                      style: const TextStyle(fontSize: 9)),
                  Text('Expiry Date : ${_fmt(expiryDate)}',
                      style: const TextStyle(fontSize: 9)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('($issuerNameEn)', style: const TextStyle(fontSize: 8)),
                  const Text('Township Red Cross Brigade Officer',
                      style: TextStyle(fontSize: 8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FULLSCREEN LANDSCAPE VIEWER
// Forces landscape orientation and scales the fixed-size card up
// to fill the available width, so it's easy to read/show someone
// across the room. Restores portrait + system UI on close.
// ═══════════════════════════════════════════════════════════════
class _FullscreenIdCard extends StatefulWidget {
  final Member member;
  final String issuerNameEn;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final bool startOnFront;

  const _FullscreenIdCard({
    required this.member,
    required this.issuerNameEn,
    required this.issuedDate,
    required this.expiryDate,
    required this.startOnFront,
  });

  @override
  State<_FullscreenIdCard> createState() => _FullscreenIdCardState();
}

class _FullscreenIdCardState extends State<_FullscreenIdCard> {
  late bool _showingFront = widget.startOnFront;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore normal portrait + visible system UI for the rest of the app
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  void _flip() => setState(() => _showingFront = !_showingFront);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _flip,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Card is authored at fixed _cardWidth x _cardHeight.
                    // Scale it up to fill ~92% of the available landscape
                    // width while preserving its exact aspect ratio, so
                    // text stays crisp instead of being re-laid-out.
                    final maxW = constraints.maxWidth * 0.92;
                    final maxH = constraints.maxHeight * 0.85;
                    final scaleByWidth = maxW / _cardWidth;
                    final scaleByHeight = maxH / _cardHeight;
                    final scale = math.min(scaleByWidth, scaleByHeight);

                    return Transform.scale(
                      scale: scale,
                      child: _showingFront
                          ? _CardFront(member: widget.member)
                          : _CardBack(
                              member: widget.member,
                              issuerNameEn: widget.issuerNameEn,
                              issuedDate: widget.issuedDate,
                              expiryDate: widget.expiryDate,
                            ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: _close,
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  tooltip: 'Close',
                ),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton.icon(
                    onPressed: _flip,
                    icon: const Icon(Icons.flip, color: Colors.white70, size: 18),
                    label: Text(
                      _showingFront ? 'Tap to flip' : 'Tap to flip back',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
