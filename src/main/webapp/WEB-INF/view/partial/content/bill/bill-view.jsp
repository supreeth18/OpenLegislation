<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div ng-controller="BillCtrl">
  <div ng-controller="BillViewCtrl" class="content-section">
    <md-content layout-padding ng-if="response.success === true">
      <md-toolbar class="md-warn md-hue-2" ng-if="bill.substitutedBy">
        <h3 class="md-warn md-hue-2">
          <i class="icon-copy prefix-icon2"></i>
          This bill has been substituted by
          <a class="white" ng-href="${ctxPath}/bills/{{bill.substitutedBy.session}}/{{bill.substitutedBy.basePrintNo}}">
            {{bill.substitutedBy.basePrintNo}} - {{bill.substitutedBy.session}}.
          </a>
        </h3>
      </md-toolbar>
      <h2 class="text-normal margin-10">{{bill.title}}</h2>
      <%-- Bill title, sponsor,and status --%>
      <md-toolbar class="md-primary md-hue-3">
        <div layout="row" layout-sm="column"
             layout-align="start center" layout-align-sm="start start">
          <div class="margin-10" layout="row" layout-align="start center" style="margin-right:60px;">
            <img class="margin-right-10"
                 ng-src="${ctxPath}/static/img/business_assets/members/mini/{{bill.sponsor.member.imgName}}"
                 style="height: 65px;"/>
            <div layout="column" ng-if="!bill.sponsor.budget">
              <div ng-if="!bill.sponsor.rules" class="text-medium">Sponsored By</div>
              <div ng-if="bill.sponsor.rules" class="text-medium bold">
                From the Rules Committee<span ng-if="bill.sponsor.member"> Via</span>
              </div>
              <h5 class="margin-top-5 no-bottom-margin">{{bill.sponsor.member.fullName}}</h5>
              <div ng-if="bill.sponsor.member" class="text-small">District {{bill.sponsor.member.districtCode}}</div>
            </div>
            <div layout="column" ng-if="bill.sponsor.budget">
              <h5 class="bold no-margin">Budget Bill</h5>
            </div>
          </div>
          <%-- NEEEEDD TO REFACTOR THIS THINGS PLZZZZZ TODO TODO --%>
          <div class="margin-bottom-10 margin-top-10" layout="column" style="margin-right:60px;min-width: 280px;"
               ng-init="statusBill = bill">
            <div class="text-medium">Status as of {{statusBill.status.actionDate | moment:'MMMM D, YYYY'}}</div>
            <h5 class="bold margin-top-5 no-bottom-margin">
              <i ng-if="bill.signed === true || bill.adopted === true" class="prefix-icon icon-check blue3"></i>
              <i ng-if="bill.vetoed === true" class="prefix-icon icon-cross"></i>
              <span>{{getStatusDesc(statusBill.status)}}</span>
            </h5>
            <milestones ng-hide="statusBill.billType.resolution"
                        milestone-arr="statusBill.milestones" chamber="statusBill.billType.chamber">
            </milestones>
          </div>
          <div class="margin-bottom-10 margin-top-10" layout="column" style="margin-right:60px;min-width: 280px;"
               ng-if="bill.substitutedBy"
               ng-init="statusBill = bill.billInfoRefs.items[bill.substitutedBy.basePrintNoStr]">
            <div class="text-medium">Status as of {{statusBill.status.actionDate | moment:'MMMM D, YYYY'}}
              <span class="bold">({{bill.substitutedBy.basePrintNoStr}})</span>
            </div>
            <h5 class="bold margin-top-5 no-bottom-margin">
              <i ng-if="bill.signed === true || bill.adopted === true" class="prefix-icon icon-check blue3"></i>
              <i ng-if="bill.vetoed === true" class="prefix-icon icon-cross"></i>
              <span>{{getStatusDesc(statusBill.status)}}</span>
            </h5>
            <milestones ng-hide="statusBill.billType.resolution"
                        milestone-arr="statusBill.milestones" chamber="statusBill.billType.chamber">
            </milestones>
          </div>
          <div class="margin-bottom-10 margin-top-10" layout="column" ng-if="bill.programInfo">
            <div class="text-medium">Bill #{{bill.programInfo.sequenceNo + 1}} on the program for </div>
            <h5 class="bold no-margin">{{bill.programInfo.name}}</h5>
          </div>
        </div>
      </md-toolbar>
      <%-- Bill amendments switcher --%>
      <md-toolbar ng-if="bill.amendments.size > 1" class="md-toolbar-tools">
        <label class="margin-right-20 text-medium">Amendment Version </label>
        <md-radio-group layout="row" layout-sm="column" ng-model="curr.amdVersion">
          <md-radio-button ng-repeat="(version, amd) in bill.amendments.items"
                           value="{{version}}" class="md-primary md-hue-2">
            <span class="text-medium bold" ng-if="$first">Original</span>
            <span class="text-medium bold" ng-if="!$first">Revision {{version}}</span>
            <span class="text-medium bold" ng-if="$last"> (Latest)</span>
            <br/>
            <span class="text-small">{{amd.publishDate | moment:'MMM D, YYYY'}}</span>
          </md-radio-button>
        </md-radio-group>
      </md-toolbar>
      <%-- Bill Tabs --%>
      <md-tabs md-selected="curr.selectedView" class="md-hue-2 margin-top-10" md-dynamic-height="true">
        <md-tab md-on-select="backToSearch()">
          <md-tab-label>
            <span><i class="icon-back prefix-icon2"></i>Search</span>
          </md-tab-label>
        </md-tab>
        <md-tab label="Details">
          <md-divider></md-divider>

          <%-- Same As Bills --%>
          <md-card class="content-card" ng-if="bill.amendments.items[curr.amdVersion].sameAs.size > 0">
            <md-subheader>Same As Bills</md-subheader>
            <md-content>
              <bill-listing bill-ids="bill.amendments.items[curr.amdVersion].sameAs.items"
                            bill-refs-map="bill.billInfoRefs.items"
                            bill-search-term="billSearch.term">
              </bill-listing>
            </md-content>
          </md-card>
          <%-- Veto Messages --%>
          <md-card class="content-card" ng-if="bill.vetoMessages.size > 0">
            <md-subheader>Veto Message From Governor</md-subheader>
            <md-content ng-repeat="veto in bill.vetoMessages.items">
              <span class="text-medium">Veto #{{veto.vetoNumber}} for Year {{veto.year}}</span>
              <md-divider></md-divider>
              <pre class="bill-full-text">{{veto.memoText}}</pre>
            </md-content>
          </md-card>
          <%-- Approval Message --%>
          <md-card class="content-card" ng-if="bill.approvalMessage">
            <md-subheader>Approval Message From Governor</md-subheader>
            <md-content>
          <span class="text-medium">
            Approval #{{bill.approvalMessage.approvalNumber}} for Year {{bill.approvalMessage.year}} - Chapter {{bill.approvalMessage.chapter}}
          </span>
              <md-divider></md-divider>
              <pre class="bill-full-text">{{bill.approvalMessage.text}}</pre>
            </md-content>
          </md-card>
          <%-- Co/Multi --%>
          <md-card layout="row" layout-sm="column" layout-align="start start" class="content-card"
                   ng-if="bill.amendments.items[curr.amdVersion].coSponsors.size > 0 ||
                    bill.amendments.items[curr.amdVersion].multiSponsors.size > 0">
            <%-- Co-Prime Sponsor --%>
            <section flex style="width:100%" ng-if="bill.additionalSponsors.size > 0">
              <md-subheader>{{bill.additionalSponsors.size}} Co-Prime Sponsor(s)</md-subheader>
              <md-content style="max-height: 200px;" class="padding-10">
                <md-list>
                  <md-list-item class="padding-left-0" ng-repeat="coPrimeSponsor in bill.additionalSponsors.items">
                    <img class="margin-right-10" ng-src="${ctxPath}/static/img/business_assets/members/mini/{{coPrimeSponsor.imgName}}"
                         style="height:60px;width:45px;"/>
                    <span class="text-medium">{{coPrimeSponsor.fullName}} - District {{coPrimeSponsor.districtCode}}</span>
                  </md-list-item>
                </md-list>
              </md-content>
            </section>
            <%-- Co Sponsor --%>
            <section flex style="width:100%" ng-if="bill.amendments.items[curr.amdVersion].coSponsors.size > 0">
              <md-subheader>{{bill.amendments.items[curr.amdVersion].coSponsors.size}} Co Sponsor(s)</md-subheader>
              <md-content style="max-height: 200px;" class="padding-10">
                <md-list>
                  <md-list-item class="padding-left-0" ng-repeat="coSponsor in bill.amendments.items[curr.amdVersion].coSponsors.items">
                      <img class="margin-right-10" ng-src="${ctxPath}/static/img/business_assets/members/mini/{{coSponsor.imgName}}"
                           style="height:60px;width:45px;"/>
                      <span class="text-medium">{{coSponsor.fullName}} - District {{coSponsor.districtCode}}</span>
                  </md-list-item>
                </md-list>
              </md-content>
            </section>
            <%-- Multi Sponsor --%>
            <section flex style="width:100%" ng-if="bill.amendments.items[curr.amdVersion].multiSponsors.size > 0">
              <md-subheader>{{bill.amendments.items[curr.amdVersion].multiSponsors.size}} Multi Sponsor(s)</md-subheader>
              <md-content style="max-height: 200px;" class="padding-10">
                <md-list>
                  <md-list-item class="padding-left-0" ng-repeat="multiSponsor in bill.amendments.items[curr.amdVersion].multiSponsors.items">
                    <img class="margin-right-10" ng-src="${ctxPath}/static/img/business_assets/members/mini/{{multiSponsor.imgName}}"
                         style="height: 60px;width:45px;"/>
                    <span class="text-medium">{{multiSponsor.fullName}} - District {{multiSponsor.districtCode}}</span>
                  </md-list-item>
                </md-list>
              </md-content>
            </section>
          </md-card>
          <%-- Enacting Clause --%>
          <md-card class="content-card" ng-if="!bill.billType.resolution">
            <md-subheader>Enacting Clause
              <md-tooltip md-direction="top">
                An enacting clause is used to briefly state a proposed change to law.
              </md-tooltip>
            </md-subheader>
            <md-content>
              <p class="text-medium">{{bill.amendments.items[curr.amdVersion].actClause | default:'Not Available'}}</p>
            </md-content>
          </md-card>
          <%-- Bill Summary --%>
          <md-card class="content-card" ng-if="!bill.billType.resolution">
            <md-subheader>Summary of Bill</md-subheader>
            <md-content>
              <p class="text-medium">{{bill.summary | default:'Not Available'}}</p>
            </md-content>
          </md-card>
          <%-- Law Section --%>
          <md-card class="content-card">
            <md-subheader>Affected Law</md-subheader>
            <md-content>
              <span class="text-medium">Primary Law Section - {{bill.amendments.items[curr.amdVersion].lawSection}}</span>
              <p class="text-medium">Law Code - {{bill.amendments.items[curr.amdVersion].lawCode | default:'N/A'}}</p>
            </md-content>
          </md-card>
          <%-- Identical Previous Legislation --%>
          <md-card class="content-card" ng-if="bill.previousVersions.size > 0">
            <md-subheader>Previous Versions of this Bill</md-subheader>
            <md-content>
              <bill-listing bill-ids="bill.previousVersions.items"
                            bill-refs-map="bill.billInfoRefs.items"
                            bill-search-term="billSearch.term">
              </bill-listing>
            </md-content>
          </md-card>
          <%-- Agenda/Cal Refs --%>
          <md-card class="content-card" ng-if="bill.calendars.size > 0 || bill.committeeAgendas.size > 0">
            <md-subheader>Agenda/Calendar References</md-subheader>
            <md-content>
              <section>
                <div ng-repeat="agenda in bill.committeeAgendas.items">
                  <a ng-if="bill.committeeAgendas.size > 0" class="gray-2-blue"
                     ng-href="${ctxPath}/agendas/{{agenda.agendaId.year}}/{{agenda.agendaId.number}}/{{agenda.committeeId.name}}">
                    Committee Agenda #{{agenda.agendaId.number}} ({{agenda.agendaId.year}}) - {{agenda.committeeId.name}}
                  </a>
                </div>
                <div ng-repeat="calendar in bill.calendars.items">
                  <a class="gray-2-blue" ng-href="${ctxPath}/calendars/{{calendar.year}}/{{calendar.calendarNumber}}#{{bill.printNo}}">
                    Senate Floor Calendar {{calendar.calendarNumber}} ({{calendar.year}})
                  </a>
                </div>
              </section>
            </md-content>
          </md-card>
        </md-tab>
        <%-- Votes --%>
        <md-tab ng-disabled="bill.votes.size == 0">
          <md-tab-label>
            Votes ({{bill.votes.size}})
          </md-tab-label>
          <md-tab-body>
            <md-content>
              <md-card class="content-card">
                <div ng-repeat="vote in bill.votes.items">
                  <div class="padding-20">
                    <h4 class="no-bottom-margin">{{vote.voteDate | moment:'MMM DD, YYYY'}} - {{vote.committee.name}}
                      <span class="capitalize">{{vote.voteType | lowercase}}</span>
                      Vote
                    </h4>
                    <p class="no-top-margin text-medium">Voted on Amendment Revision: {{vote.version | prettyAmendVersion}}</p>
                    <md-divider></md-divider>
                    <div layout="row" layout-align="center center" layout-sm="column" layout-align-sm="start start">
                      <div flex>
                        <table class="bill-votes-table">
                          <thead>
                          <tr>
                            <th style="min-width: 100px;">Vote</th>
                            <th>Count</th>
                          </tr>
                          </thead>
                          <tbody>
                          <tr ng-class="{'positive': (voteType === 'AYE' || voteType === 'AYEWR'),
                                     'negative': (voteType === 'NAY')}"
                              ng-repeat="(voteType, votes) in vote.memberVotes.items">
                            <td>{{voteType | voteTypeFilter}}</td>
                            <td>{{votes.size}}</td>
                          </tr>
                          </tbody>
                        </table>
                      </div>
                      <div flex>
                        <md-content class="margin-left-16 padding-10" style="max-height: 200px;">
                          <md-list ng-repeat="(voteType, votes) in vote.memberVotes.items">
                            <md-list-item ng-repeat="voteItem in votes.items">
                              <div style="width:80px;" class="md-tile-left margin-right-10">
                                <h5 style="margin:10px;">{{voteType}}</h5>
                              </div>
                              <div class="md-tile-left">
                                <img class="margin-right-10" ng-src="${ctxPath}/static/img/business_assets/members/mini/{{voteItem.imgName}}"
                                     style="height: 35px;width:29px;"/>
                              </div>
                              <div style="padding:0" class="md-tile-content">
                                <span class="text-medium">{{voteItem.fullName}}</span>
                              </div>
                            </md-list-item>
                            <md-divider></md-divider>
                          </md-list>
                        </md-content>
                      </div>
                    </div>
                  </div>
                </div>
              </md-card>
            </md-content>
          </md-tab-body>
        </md-tab>
        <%-- Sponsor Memo --%>
        <md-tab label="Memo" ng-disabled="bill.billType.resolution">
          <md-divider></md-divider>
          <md-card class="content-card">
            <md-subheader>
              Sponsor's Memorandum
            </md-subheader>
            <md-content ng-if="bill.amendments.items[curr.amdVersion].memo">
              <pre class="bill-full-text"
                   ng-bind="bill.amendments.items[curr.amdVersion].memo"></pre>
            </md-content>
            <md-content ng-if="bill.billType.chamber == 'ASSEMBLY'">
              <div class="text-medium padding-20">Sponsor memos are not provided for Assembly bills.
                <p ng-if="bill.amendments.items[curr.amdVersion].sameAs.size > 0"
                   ng-init="sameAsBill = bill.amendments.items[curr.amdVersion].sameAs.items[0]">
                  You can view the sponsor memo for the Senate version of this bill here:
                  <a target="_blank"
                     ng-href="${ctxPath}/bills/{{sameAsBill.session}}/{{sameAsBill.basePrintNo}}?view=2">{{sameAsBill.basePrintNo}}</a>.</p>
              </div>
            </md-content>
            <md-content ng-if="!bill.amendments.items[curr.amdVersion].memo && bill.billType.chamber == 'SENATE'">
              <div class="text-medium padding-20">Sponsor memo is not available.</div>
            </md-content>
          </md-card>
        </md-tab>
        <%-- Bill Actions --%>
        <md-tab>
          <md-tab-label>
            Actions ({{bill.actions.size}})
          </md-tab-label>
          <md-tab-body>
            <md-divider></md-divider>
            <div>
              <md-card class="content-card">
                <md-subheader>
                  Bill Actions
                </md-subheader>
                <md-content>
                  <md-list>
                    <md-list-item class="md-2-line" ng-repeat="action in bill.actions.items">
                      <div class="md-list-item-text">
                        <h2 class="text-medium">{{action.date | moment:'MMMM D, YYYY'}} - {{action.chamber}} - <span class="gray7">{{action.billId.printNo}}</span></h2>
                        <h3 class="text-medium capitalize">{{action.text | lowercase}}</h3>
                      </div>
                    </md-list-item>
                  </md-list>
                </md-content>
              </md-card>
            </div>
          </md-tab-body>
        </md-tab>
        <%-- Bill Text --%>
        <md-tab label="Full Text">
          <md-tab-body>
            <md-divider></md-divider>
            <section>
              <md-card class="content-card" ng-if="bill.amendments.size > 1">
                <md-content layout="row">
                  <i class="prefix-icon icon-flow-branch margin-top-5"></i>Compare with revision:
                  <select ng-model="curr.compareVersion" ng-change="diffBills()" class="margin-left-20 white-bg">
                    <option value="None">Self</option>
                    <option ng-repeat="(version, amd) in bill.amendments.items" ng-if="version !== curr.amdVersion">
                      {{version | prettyAmendVersion}}
                    </option>
                  </select>
                </md-content>
              </md-card>
              <md-card class="content-card">
                <md-subheader>Full Text</md-subheader>
                <md-content class="margin-10 padding-20">
                <span ng-if="!loading && !bill.amendments.items[curr.amdVersion].fullText">
                  Not available.</span>
                  <span ng-if="loading">Loading full text, please wait.</span>
                  <div ng-if="bill.amendments.items[curr.amdVersion].fullText">
                    <pre ng-if="!diffHtml" class="margin-left-20 bill-full-text">{{bill.amendments.items[curr.amdVersion].fullText}}</pre>
                    <pre ng-if="diffHtml" class="margin-left-20 bill-full-text" ng-bind-html="diffHtml"></pre>
                  </div>
                </md-content>
              </md-card>
            </section>
          </md-tab-body>
        </md-tab>
        <%-- Updates --%>
        <md-tab md-on-select="initialGetUpdates()">
          <md-tab-label>
            Updates
          </md-tab-label>
          <md-tab-body>
            <md-divider></md-divider>
            <div>
              <md-card class="content-card">
                <md-content layout="row" layout-sm="column">
                  <div flex>
                    <label>Filter by update type: </label>
                    <select ng-model="curr.updateTypeFilter" ng-change="getUpdates()" class="margin-left-10">
                      <option value="">All</option>
                      <option value="action">Action</option>
                      <option value="active_version">Active Version</option>
                      <option value="approval">Approval Memo</option>
                      <option value="cosponsor">Co Sponsor</option>
                      <option value="act_clause">Enacting Clause</option>
                      <option value="fulltext">Full Text</option>
                      <option value="law">Law</option>
                      <option value="memo">Memo</option>
                      <option value="multisponsor">Multi Sponsor</option>
                      <option value="sponsor">Sponsor</option>
                      <option value="status">Status</option>
                      <option value="summary">Summary</option>
                      <option value="title">Title</option>
                      <option value="veto">Veto</option>
                      <option value="vote">Vote</option>
                    </select>
                  </div>
                  <div flex>
                    <label class="margin-left-10">Order</label>
                    <select ng-model="curr.updateOrder" ng-change="getUpdates()" class="margin-left-10">
                      <option value="asc">Oldest First</option>
                      <option value="desc">Newest First</option>
                    </select>
                  </div>
                </md-content>
              </md-card>
              <update-list update-response="updateHistoryResponse" show-details="true"></update-list>
            </div>
          </md-tab-body>
        </md-tab>
      </md-tabs>
    </md-content>
    <section ng-if="response.success === false">
      <md-card>
        <md-content class="content-card padding-20">
          <h3 class="red1">This bill could not be retrieved. It's likely that the bill does not exist or has not been published yet.</h3>
          <h5>Please note that Open Legislation only has bill data starting from the 2009 session year. Bills prior to 2009
          should be obtained via LBDC directly.</h5>
        </md-content>
      </md-card>
    </section>
  </div>
</div>