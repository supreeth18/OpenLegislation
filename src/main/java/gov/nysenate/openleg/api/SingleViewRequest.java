package gov.nysenate.openleg.api;

import gov.nysenate.openleg.api.QueryBuilder.QueryBuilderException;
import gov.nysenate.openleg.api.servlets.ApiServlet.ApiEnum;
import gov.nysenate.openleg.model.SenateObject;
import gov.nysenate.openleg.model.bill.Bill;
import gov.nysenate.openleg.model.bill.BillEvent;
import gov.nysenate.openleg.model.bill.Vote;
import gov.nysenate.openleg.model.calendar.Calendar;
import gov.nysenate.openleg.model.committee.Meeting;
import gov.nysenate.openleg.model.transcript.Transcript;
import gov.nysenate.openleg.search.SearchEngine;
import gov.nysenate.openleg.util.TextFormatter;

import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class SingleViewRequest extends AbstractApiRequest {
	String format;
	String type;
	String id;
	
	public SingleViewRequest(HttpServletRequest request, HttpServletResponse response,
			String format, String type, String id) {
		super(request, response, 1, 1, getApiEnum(SingleView.values(),type));
		this.format = thisOrThat(format, DEFAULT_FORMAT);
		this.type = type;
		this.id = id;
	}

	public void fillRequest() {
		SenateObject so = SearchEngine.getInstance().getSenateObject(id,
				type, apiEnum.clazz());
		
		request.setAttribute(type , so);
		
		try {
			if(type.equals("bill")) {
				String rType = "action";
				String rQuery = QueryBuilder.build().otype(rType).and().relatedBills("billno", id).query();
				ArrayList<BillEvent> billEvents = SearchEngine.getInstance().getSenateObjects(rQuery, BillEvent.class);
				request.setAttribute("related-" + rType, billEvents);
		
				rType = "bill";
				rQuery = QueryBuilder.build().otype(rType).and().relatedBills("oid", id).query();
				ArrayList<Bill> bills = SearchEngine.getInstance().getSenateObjects(rQuery, Bill.class);
				request.setAttribute("related-" + rType, bills);
		
				rType = "meeting";
				rQuery = QueryBuilder.build().otype(rType).and().keyValue("bills", id).query();
				ArrayList<Meeting> meetings = SearchEngine.getInstance().getSenateObjects(rQuery, Meeting.class);
				request.setAttribute("related-" + rType, meetings);
				
				rType = "calendar";
				rQuery = QueryBuilder.build().otype(rType).and().keyValue("bills", id).query();
				ArrayList<Calendar> calendars = SearchEngine.getInstance().getSenateObjects(rQuery, Calendar.class);
				request.setAttribute("related-" + rType, calendars);
				
				rType = "vote";
				rQuery = QueryBuilder.build().otype(rType).and().keyValue("billno", id).query();
				ArrayList<Vote> votes = SearchEngine.getInstance().getSenateObjects(rQuery, Vote.class);
				request.setAttribute("related-" + rType, votes);
			}
		} catch (QueryBuilderException e) {
			e.printStackTrace();
		}
	}

	public String getView() {
		return TextFormatter.append("/views/", type, "-", format, ".jsp");
	}
	
	public boolean isValid() {
		return type != null && id != null;
	}
	
	public enum SingleView implements ApiEnum {
		BILL		("bill",		Bill.class, 		new String[] {"html", "json", "mobile", "xml", 
																					  "csv", "html-print", "lrs-print"}),
		CALENDAR	("calendar",	Calendar.class, 	new String[] {"html", "json", "mobile", "xml"}),
		MEETING		("meeting", 	Meeting.class, 		new String[] {"html", "json", "mobile", "xml"}),
		TRANSCRIPT	("transcript", 	Transcript.class, 	new String[] {"html", "json", "mobile", "xml"});
		
		public final String view;
		public final Class<? extends SenateObject> clazz;
		public final String[] formats;
		
		private SingleView(final String view, final Class<? extends SenateObject> clazz, final String[] formats) {
			this.view = view;
			this.clazz = clazz;
			this.formats = formats;
		}
		
		public String view() {
			return view;
		}
		public String[] formats() {
			return formats;
		}
		public Class<? extends SenateObject> clazz() {
			return clazz;
		}
	}
}