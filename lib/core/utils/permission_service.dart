import '../constants/app_constants.dart';
import '../../data/models/models.dart';

// ─────────────────────────────────────────────
// PERMISSION SERVICE
// Central place for all access control logic
// ─────────────────────────────────────────────
class PermissionService {
  PermissionService._();

  // ─── MASTER ACCESS CHECK ─────────────────
  /// Brigade Commander, Deputy, Brigade Office Chief
  /// + Chairperson all have full access
  static bool hasMasterAccess(Member member) {
    if (member.isChairperson) return true;
    if (member.rank == MemberRank.brigadeCommander) return true;
    if (member.rank == MemberRank.deputyBrigadeCommander) return true;
    if (member.isBrigadeOfficeChief) return true;
    return false;
  }

  // ─── UNIT SCOPE ──────────────────────────
  /// Determine what scope a member has access to
  static UnitScope getUnitScope(Member member) {
    // Master access — entire brigade
    if (hasMasterAccess(member)) return UnitScope.brigadWide;

    // Special brigade authority granted by Brigade Commander
    if (member.hasBrigadeOfficeAuthority) return UnitScope.brigadWide;

    // Any rank assigned to Brigade Office — brigade wide
    if (member.unitType == UnitType.brigadeOffice) return UnitScope.brigadWide;

    // Company Office members — company wide
    if (member.unitType == UnitType.companyOffice) return UnitScope.companyWide;

    // Platoon Office members — platoon wide
    if (member.unitType == UnitType.platoonOffice) return UnitScope.platoonWide;

    // Field assignments by rank
    // (brigadeCommander/deputyBrigadeCommander/brigadeOffice cases are
    // already handled above via hasMasterAccess() and unitType checks —
    // if we reach here for those ranks, treat as field fallback below)
    switch (member.rank) {
      case MemberRank.brigadeCommander:
      case MemberRank.deputyBrigadeCommander:
        return UnitScope.brigadWide;

      case MemberRank.companyCommander:
      case MemberRank.deputyCompanyCommander:
        return UnitScope.companyWide;

      case MemberRank.platoonLeader:
      case MemberRank.companySergeantMajor:
      case MemberRank.platoonSergeant:
        return UnitScope.platoonWide;

      case MemberRank.warrantOfficer:
      case MemberRank.sergeantClerk:
        // These are only brigade-wide if in Brigade Office
        // (already handled above) — if we reach here they are field
        return UnitScope.platoonWide;

      case MemberRank.sectionLeader:
      case MemberRank.deputySectionLeader:
        return UnitScope.sectionWide;

      case MemberRank.private:
        return UnitScope.ownOnly;
    }
  }

  // ─── MEMBER VISIBILITY ───────────────────
  static bool canViewMember(Member viewer, Member target) {
    if (hasMasterAccess(viewer)) return true;
    if (viewer.id == target.id) return true;

    final scope = getUnitScope(viewer);
    switch (scope) {
      case UnitScope.brigadWide:
        return true;
      case UnitScope.companyWide:
        return target.companyNo == viewer.companyNo;
      case UnitScope.platoonWide:
        return target.companyNo == viewer.companyNo &&
            target.platoonNo == viewer.platoonNo;
      case UnitScope.sectionWide:
        return target.companyNo == viewer.companyNo &&
            target.platoonNo == viewer.platoonNo &&
            target.sectionNo == viewer.sectionNo;
      case UnitScope.ownOnly:
        return target.id == viewer.id;
    }
  }

  // ─── MEMBER MANAGEMENT ───────────────────
  static bool canManageMember(Member viewer, Member target) {
    if (target.rank == MemberRank.private &&
        viewer.rank == MemberRank.private) return false;
    if (!RankHelper.isHigherThan(viewer.rank, target.rank) &&
        viewer.id != target.id) return false;

    // Platoon Leader can VIEW full detail across their whole company
    // (via canViewFullDetail), but may only EDIT members within their
    // own platoon — not other platoons in the same company.
    if (viewer.rank == MemberRank.platoonLeader &&
        target.platoonNo != viewer.platoonNo) {
      return false;
    }

    return canViewMember(viewer, target);
  }

  // ─── DUTY ASSIGNMENT ─────────────────────
  static bool canAssignDuty(Member member) {
    if (hasMasterAccess(member)) return true;
    if (member.unitType == UnitType.brigadeOffice) return true;
    if (member.unitType == UnitType.companyOffice) return true;
    if (member.unitType == UnitType.platoonOffice) return true;
    return RankHelper.isOfficerRank(member.rank) ||
        member.rank == MemberRank.companySergeantMajor ||
        member.rank == MemberRank.platoonSergeant ||
        member.rank == MemberRank.sectionLeader ||
        member.rank == MemberRank.deputySectionLeader;
  }

  // ─── APPROVE REPORTS ─────────────────────
  static bool canApproveReport(Member approver, Member reportSubmitter) {
    if (hasMasterAccess(approver)) return true;
    if (approver.unitType == UnitType.brigadeOffice) return true;
    if (!RankHelper.isHigherThan(approver.rank, reportSubmitter.rank)) {
      return false;
    }
    return canViewMember(approver, reportSubmitter);
  }

  // ─── GENERATE REPORTS ────────────────────
  static bool canGenerateReports(Member member) {
    if (hasMasterAccess(member)) return true;
    return member.unitType == UnitType.brigadeOffice;
  }

  // ─── VIEW PUBLISHED REPORTS ──────────────
  static bool canViewPublishedReports(Member member) => true; // All members

  // ─── VIEW DRAFT REPORTS ──────────────────
  static bool canViewDraftReports(Member member) {
    if (hasMasterAccess(member)) return true;
    if (member.unitType == UnitType.brigadeOffice) return true;
    return RankHelper.isOfficerRank(member.rank);
  }

  // ─── INVESTIGATIONS ──────────────────────
  static bool canViewInvestigation(
    Member viewer,
    Investigation investigation,
  ) {
    // Recusal — accused or witness locked out regardless of rank
    if (investigation.accusedMemberIds.contains(viewer.id)) return false;
    if (investigation.witnessMemberIds.contains(viewer.id)) return false;

    // Master access
    if (hasMasterAccess(viewer)) return true;

    // Brigade Office Chief
    if (viewer.isBrigadeOfficeChief) return true;

    // Committee members — only while ongoing
    if (investigation.committeeMemberIds.contains(viewer.id)) {
      final isOngoing = investigation.status != InvestigationStatus.closed &&
          investigation.status != InvestigationStatus.concluded &&
          investigation.status != InvestigationStatus.appealConcluded;
      if (isOngoing) return true;

      // Grace period — 1 week after concluded
      if (investigation.concludedDate != null) {
        final daysSince =
            DateTime.now().difference(investigation.concludedDate!).inDays;
        if (daysSince <= 7) return true;
      }
    }

    // Appeal committee — while appeal ongoing
    if (investigation.appealCommitteeMemberIds.contains(viewer.id)) {
      final isAppealing =
          investigation.status == InvestigationStatus.appealed ||
          investigation.status == InvestigationStatus.appealReview;
      if (isAppealing) return true;
    }

    return false;
  }

  static bool canManageInvestigation(
    Member viewer,
    Investigation investigation,
  ) {
    // Recusal
    if (investigation.accusedMemberIds.contains(viewer.id)) return false;
    if (investigation.witnessMemberIds.contains(viewer.id)) return false;

    // Master access
    if (hasMasterAccess(viewer)) return true;

    // Committee members — only while ongoing and not related
    if (investigation.committeeMemberIds.contains(viewer.id)) {
      final isOngoing = investigation.status != InvestigationStatus.closed &&
          investigation.status != InvestigationStatus.concluded;
      return isOngoing;
    }

    return false;
  }

  static bool canViewSealedAttachment(
    Member viewer,
    Investigation investigation,
  ) {
    // Recusal first
    if (investigation.accusedMemberIds.contains(viewer.id)) return false;
    if (investigation.witnessMemberIds.contains(viewer.id)) return false;

    // Master access — no approval needed
    if (viewer.rank == MemberRank.brigadeCommander) return true;
    if (viewer.rank == MemberRank.deputyBrigadeCommander) return true;
    if (viewer.isChairperson) return true;

    // Others need explicit approval — checked via approvedSealedViewers list
    return investigation.approvedSealedViewers.contains(viewer.id);
  }

  // ─── PUNISHMENTS ─────────────────────────
  static bool canViewPunishment(
    Member viewer,
    Punishment punishment,
    Investigation? relatedInvestigation,
  ) {
    // Punished member sees own record always
    if (viewer.id == punishment.memberId) return true;

    // Master access
    if (hasMasterAccess(viewer)) return true;

    // Brigade Office members
    if (viewer.unitType == UnitType.brigadeOffice) return true;

    // Investigation committee — 1 week grace after concluded
    if (relatedInvestigation != null) {
      if (relatedInvestigation.committeeMemberIds.contains(viewer.id)) {
        if (relatedInvestigation.concludedDate != null) {
          final daysSince = DateTime.now()
              .difference(relatedInvestigation.concludedDate!)
              .inDays;
          if (daysSince <= 7) return true;
        }
      }
    }

    // Higher rank same company rule
    // Get punished member to check company
    // Higher rank can view lower rank in same company
    return false; // Resolved at runtime with punished member data
  }

  static bool canViewPunishmentWithTarget(
    Member viewer,
    Punishment punishment,
    Member punishedMember,
    Investigation? relatedInvestigation,
  ) {
    if (viewer.id == punishment.memberId) return true;
    if (hasMasterAccess(viewer)) return true;
    if (viewer.unitType == UnitType.brigadeOffice) return true;

    // Committee grace period
    if (relatedInvestigation != null &&
        relatedInvestigation.committeeMemberIds.contains(viewer.id)) {
      if (relatedInvestigation.concludedDate != null) {
        final days = DateTime.now()
            .difference(relatedInvestigation.concludedDate!)
            .inDays;
        if (days <= 7) return true;
      }
    }

    // Higher rank same company
    if (viewer.companyNo == punishedMember.companyNo &&
        RankHelper.isHigherThan(viewer.rank, punishedMember.rank)) {
      return true;
    }

    return false;
  }

  // ─── BLOOD DONATIONS ─────────────────────
  static bool canViewBloodDonors(Member member) {
    if (hasMasterAccess(member)) return true;
    if (member.unitType == UnitType.brigadeOffice) return true;
    if (RankHelper.isOfficerRank(member.rank)) return true;
    if (member.youthGroupRole != null &&
        member.youthGroup == YouthGroup.bloodDonations) return true;
    return false;
  }

  static bool canEditBloodDonors(Member member) {
    return member.youthGroup == YouthGroup.bloodDonations &&
        member.youthGroupRole != null;
  }

  static bool canTriggerEmergencySearch(Member member) {
    if (hasMasterAccess(member)) return true;
    if (member.unitType == UnitType.brigadeOffice) return true;
    if (RankHelper.isOfficerRank(member.rank)) return true;
    if (member.youthGroup == YouthGroup.bloodDonations) return true;
    return false;
  }

  // ─── FUND LEDGER ─────────────────────────
  static bool canViewFund(Member member) {
    if (hasMasterAccess(member)) return true;
    if (member.unitType == UnitType.brigadeOffice) return true;
    return RankHelper.isOfficerRank(member.rank);
  }

  static bool canEditFundDirectly(Member member) {
    if (member.rank == MemberRank.brigadeCommander) return true;
    if (member.rank == MemberRank.deputyBrigadeCommander) return true;
    if (member.isBrigadeOfficeChief) return true;
    return false;
  }

  static bool canSubmitFundForApproval(Member member) {
    if (canEditFundDirectly(member)) return true;
    return member.unitType == UnitType.brigadeOffice;
  }

  // ─── CERTIFICATES ────────────────────────
  static bool canViewCertificate(Member viewer, Member owner) {
    if (viewer.id == owner.id) return true;
    if (hasMasterAccess(viewer)) return true;
    if (viewer.unitType == UnitType.brigadeOffice) return true;
    return canViewMember(viewer, owner) &&
        RankHelper.isHigherThan(viewer.rank, owner.rank);
  }

  // ─── ARCHIVE ─────────────────────────────
  static bool canViewArchive(Member member) {
    if (hasMasterAccess(member)) return true;
    if (member.unitType == UnitType.brigadeOffice) return true;
    if (member.rank == MemberRank.companyCommander) return true;
    if (member.rank == MemberRank.deputyCompanyCommander) return true;
    return false;
  }

  // ─── SETTINGS ────────────────────────────
  static bool canViewSettings(Member member) {
    if (hasMasterAccess(member)) return true;
    if (member.rank == MemberRank.sergeantClerk &&
        member.unitType == UnitType.brigadeOffice) return true;
    return false;
  }

  static bool canEditSettingsDirectly(Member member) {
    return hasMasterAccess(member);
  }

  static bool canEditSettingsWithApproval(Member member) {
    return member.rank == MemberRank.sergeantClerk &&
        member.unitType == UnitType.brigadeOffice;
  }

  // ─── YOUTH WING REPORTS ──────────────────
  static bool canApproveYouthReport(Member member) {
    if (member.rank == MemberRank.brigadeCommander) return true;
    if (member.rank == MemberRank.deputyBrigadeCommander) return true;
    if (member.isBrigadeOfficeChief) return true;
    return false;
  }

  static bool canViewYouthReport(
    Member viewer,
    YouthGroup group,
    bool isPublic,
  ) {
    if (isPublic) return true;
    if (hasMasterAccess(viewer)) return true;
    if (viewer.unitType == UnitType.brigadeOffice) return true;
    if (RankHelper.isOfficerRank(viewer.rank)) return true;
    if (viewer.youthGroup == group) return true;
    return false;
  }

  // ─── DISPATCH ────────────────────────────
  static bool canCreateDispatch(Member member) {
    if (hasMasterAccess(member)) return true;
    return member.unitType == UnitType.brigadeOffice;
  }

  static bool canSuggestDispatchMember(Member member) {
    return member.rank == MemberRank.companyCommander ||
        member.rank == MemberRank.deputyCompanyCommander;
  }

  static bool canConfirmDispatch(Member member) {
    return member.rank == MemberRank.brigadeCommander ||
        member.rank == MemberRank.deputyBrigadeCommander ||
        member.isBrigadeOfficeChief;
  }

  // ─── DUTY IN SPECIFIC DUTY CONTEXT ───────
  /// Within a duty, authority comes from duty role not permanent rank
  static bool canMakeDecisionInDuty(
    Member member,
    Duty duty,
  ) {
    // Check duty role first
    final dutyMember = duty.members
        .where((dm) => dm.memberId == member.id)
        .firstOrNull;
    if (dutyMember == null) return false;

    if (duty.scale == DutyScale.largeScale) {
      return dutyMember.roleInDuty == DutyRoleInDuty.commander ||
          dutyMember.roleInDuty == DutyRoleInDuty.officer;
    } else {
      return dutyMember.roleInDuty == DutyRoleInDuty.officer;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MODULE 4 ADDITIONS — List visibility vs Detail visibility
  //
  // Two separate questions, deliberately kept apart:
  //   1. canSeeInMemberList — does this member show up at all when
  //      `viewer` searches/browses the Members list? (Brigade-wide
  //      for everyone — see method below.)
  //   2. canViewFullDetail — once visible, can `viewer` open the
  //      full Info/Analytics/ID Card tabs, or only contact-info-level
  //      fields (name, rank, phone, email, unit/company)?
  //
  // NOTE: canViewMember (above) is left untouched — it's still used
  // by duty/report/other modules for their own scope checks. These
  // new methods are specific to the Members screen.
  // ═══════════════════════════════════════════════════════════

  /// Can `viewer` see `target` show up in the Members list at all?
  /// Can `viewer` see `target` show up in the Members list at all?
  /// Brigade-wide for EVERYONE — the list itself shows the entire
  /// roster to every member, regardless of rank or company. What's
  /// restricted is the DETAIL shown once you tap in (see
  /// canViewFullDetail below) — not whether the member appears here.
  static bool canSeeInMemberList(Member viewer, Member target) {
    return true;
  }

  /// Can `viewer` see `target`'s FULL detail — Info tab, Analytics tab,
  /// AND ID Card tab all derive from this single rule. If false, the
  /// caller should hide those tabs entirely (not show a locked
  /// placeholder) and fall back to contact-info-only fields (name,
  /// rank, phone, email, unit/company) wherever target is shown.
  ///
  /// Rules, in order:
  ///   1. Own profile — always full detail.
  ///   2. Master Access/Admin viewing a target who is NOT themselves
  ///      Master Access/Admin — always full detail, regardless of
  ///      company (Master Access tier sees everyone "below" it fully).
  ///   3. Master Access/Admin viewing ANOTHER Master Access/Admin
  ///      target — falls through to rule 4 (rank order still applies
  ///      between Master Access holders, e.g. Deputy viewing Brigade
  ///      Commander needs to outrank, which they don't, so no detail).
  ///   4. Everyone else: same company AND viewer outranks target.
  ///      Different company, or same company without outranking →
  ///      contact-info-only.
  static bool canViewFullDetail(Member viewer, Member target) {
    if (viewer.id == target.id) return true;

    final viewerIsMaster = hasAdminOrMasterAccess(viewer);
    final targetIsMaster = hasAdminOrMasterAccess(target);

    // Master Access/Admin viewing a non-Master target — always full
    // detail, regardless of company.
    if (viewerIsMaster && !targetIsMaster) return true;

    // Both are Master Access/Admin (e.g. Brigade Commander viewing
    // Deputy, or Deputy viewing Brigade Commander) — rank order decides
    // between them directly. This does NOT go through the company-match
    // check below, since Brigade Office members share no companyNo.
    if (viewerIsMaster && targetIsMaster) {
      return RankHelper.isHigherThan(viewer.rank, target.rank);
    }

    // Viewer is not Master Access. A non-Master viewer can never see a
    // Master Access target's detail (Brigade Office is always
    // protected from below).
    if (targetIsMaster) return false;

    // Standard same-company + outranks rule for everyone else.
    if (viewer.companyNo != target.companyNo) return false;
    return RankHelper.isHigherThan(viewer.rank, target.rank);
  }

  /// Can `viewer` see `target`'s ID card fullscreen landscape view?
  /// Self or Master Access/Admin only — unrelated to detail visibility.
  /// Can `viewer` see `target`'s ID card fullscreen landscape view?
  /// STRICTLY self-only — no exception for any rank, including Master
  /// Access/Admin. Fullscreen is for showing your OWN card to someone
  /// in person; it is never used to display someone else's card.
  static bool canViewIdCardFullscreen(Member viewer, Member target) {
    return viewer.id == target.id;
  }

  // ═══════════════════════════════════════════════════════════
  // MODULE 4 ADDITIONS — Add Member permissions
  // ═══════════════════════════════════════════════════════════

  /// Can `member` add a new member directly (no approval needed)?
  /// Master Access, Admin, Company Commander, Deputy Company Commander.
  static bool canAddMemberDirectly(Member member) {
    if (hasAdminOrMasterAccess(member)) return true;
    if (member.rank == MemberRank.companyCommander) return true;
    if (member.rank == MemberRank.deputyCompanyCommander) return true;
    return false;
  }

  /// Can `member` propose a new member (needs Company Commander approval)?
  /// Platoon Leader and Section Leader only.
  static bool canProposeNewMember(Member member) {
    if (member.rank == MemberRank.platoonLeader) return true;
    if (member.rank == MemberRank.sectionLeader) return true;
    return false;
  }

  /// Can `member` add OR propose a new member at all (used to show the
  /// Add Member button — actual flow differs based on which is true).
  static bool canAddOrProposeMember(Member member) {
    return canAddMemberDirectly(member) || canProposeNewMember(member);
  }

  /// Can `approver` approve a pending member proposal submitted within
  /// their company? Only Company Commander / Deputy Company Commander
  /// of the SAME company as the proposer, or Master Access/Admin.
  static bool canApproveNewMemberProposal(Member approver, Member proposer) {
    if (hasAdminOrMasterAccess(approver)) return true;
    final isCompanyLead = approver.rank == MemberRank.companyCommander ||
        approver.rank == MemberRank.deputyCompanyCommander;
    if (!isCompanyLead) return false;
    return approver.companyNo == proposer.companyNo;
  }


  /// Admin role has same power as Master Access for most things,
  /// EXCEPT acting on Deputy Brigade Commander+ requires approval
  /// (handled via adminApprovalTierFor at the workflow layer).
  static bool hasAdminOrMasterAccess(Member member) {
    return member.isAdminRole || hasMasterAccess(member);
  }

  /// Can `actor` toggle `target`'s availability directly (no approval)?
  static bool canToggleAvailabilityDirectly(Member actor, Member target) {
    return hasAdminOrMasterAccess(actor);
  }

  /// Can `actor` request to toggle `target`'s availability
  /// (requires approval from actor's own higher rank)?
  static bool canRequestAvailabilityToggle(Member actor, Member target) {
    if (hasAdminOrMasterAccess(actor)) return true; // direct, not request

    // Self-request: any member can request their own availability change
    if (actor.id == target.id) return true;

    // Higher rank requesting for someone below them, same unit scope
    final actorIsHigher = RankHelper.isHigherThan(actor.rank, target.rank);
    if (!actorIsHigher) return false;

    if (actor.unitType == UnitType.brigadeOffice) return true;
    return actor.companyNo == target.companyNo;
  }

  /// Active/Inactive status — direct change, no approval. ONLY Master
  /// Access or Admin role. Nobody (including self) can change their
  /// own active/inactive this way. This is the path for disciplinary
  /// suspension/dismissal (see Module 16) — for long leave/overseas,
  /// use canRequestInactiveLeaveToggle below instead.
  static bool canChangeActiveStatus(Member actor, Member target) {
    return hasAdminOrMasterAccess(actor);
  }

  /// Long leave / overseas Active ↔ Inactive toggle — SAME approval
  /// pattern as Available/Not Available:
  ///   - Master Access/Admin: direct, no approval.
  ///   - Self: can request own long-leave status, needs approval from
  ///     own higher rank.
  ///   - Higher rank (same unit scope): can request on someone else's
  ///     behalf, needs approval from THEIR own higher rank.
  /// This is distinct from canChangeActiveStatus, which is the
  /// disciplinary/direct-only path.
  static bool canRequestInactiveLeaveToggle(Member actor, Member target) {
    if (hasAdminOrMasterAccess(actor)) return true; // direct, not request

    // Self-request: any member can request their own long-leave status
    if (actor.id == target.id) return true;

    // Higher rank requesting for someone below them, same unit scope
    final actorIsHigher = RankHelper.isHigherThan(actor.rank, target.rank);
    if (!actorIsHigher) return false;

    if (actor.unitType == UnitType.brigadeOffice) return true;
    return actor.companyNo == target.companyNo;
  }

  /// Is `member` eligible to be assigned to a duty, meeting, or class?
  /// Used by assignment pickers in later modules (Duties, Meetings,
  /// Classes) to filter out members who are inactive for long leave.
  /// NOT the same as `isAvailable` (short-term, day-to-day scheduling)
  /// — this specifically excludes the long-leave/overseas case.
  static bool isEligibleForAssignment(Member member) {
    if (member.status == MemberStatus.inactive &&
        member.inactiveReason != null) {
      return false;
    }
    if (member.status == MemberStatus.suspended) return false;
    if (member.status == MemberStatus.dismissed) return false;
    return true;
  }

  /// Rank/role changes — ONLY Master Access or Admin role.
  /// Self cannot change own rank/role even if Master Access
  /// (must go through formal order process — UI enforces this).
  static bool canChangeRankOrRole(Member actor, Member target) {
    if (actor.id == target.id) return false; // never self
    return hasAdminOrMasterAccess(actor);
  }

  /// Approval tier needed for Admin (non-Master-Access) to act on `target`.
  /// Returns null if no approval needed (target is below Deputy rank).
  /// Returns 'single' if needs 1 of Brigade Commander/Deputy.
  /// Returns 'double' if needs 2 of Chairperson/Commander/Deputy.
  static String? adminApprovalTierFor(Member target) {
    if (target.isChairperson || target.rank == MemberRank.brigadeCommander) {
      return 'double';
    }
    if (target.rank == MemberRank.deputyBrigadeCommander ||
        target.isBrigadeOfficeChief) {
      return 'single';
    }
    return null; // Platoon Leader and below — Admin can act directly
  }
}