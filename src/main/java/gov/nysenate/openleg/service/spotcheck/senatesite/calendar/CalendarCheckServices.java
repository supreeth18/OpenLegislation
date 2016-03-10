package gov.nysenate.openleg.service.spotcheck.senatesite.calendar;

import gov.nysenate.openleg.model.bill.BillId;
import gov.nysenate.openleg.model.calendar.*;
import gov.nysenate.openleg.model.calendar.spotcheck.SpotcheckCalendarId;
import gov.nysenate.openleg.model.spotcheck.ReferenceDataNotFoundEx;
import gov.nysenate.openleg.model.spotcheck.SpotCheckMismatchType;
import gov.nysenate.openleg.model.spotcheck.SpotCheckObservation;
import gov.nysenate.openleg.model.spotcheck.senatesite.calendar.SenateSiteCalendar;
import gov.nysenate.openleg.service.spotcheck.base.BaseSpotCheckService;
import org.apache.commons.lang3.NotImplementedException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by PKS on 2/25/16.
 */
@Service
public class CalendarCheckServices extends BaseSpotCheckService<SpotcheckCalendarId, Calendar, SenateSiteCalendar> {
    @Override
    public SpotCheckObservation<SpotcheckCalendarId> check(Calendar content) throws ReferenceDataNotFoundEx {
        throw new NotImplementedException(":P");
    }

    @Override
    public SpotCheckObservation<SpotcheckCalendarId> check(Calendar content, LocalDateTime start, LocalDateTime end) throws ReferenceDataNotFoundEx {
        throw new NotImplementedException(":P");
    }

    @Override
    public SpotCheckObservation<SpotcheckCalendarId> check(Calendar content, SenateSiteCalendar reference) {
        SpotCheckObservation<SpotcheckCalendarId> observation = new SpotCheckObservation<>(reference.getReferenceId(),reference.getSpotCheckCalendarId());
        checkCalendarId(content,reference,observation);
        if(reference.getCalendarType() == CalendarType.ACTIVE_LIST){
            checkActiveList(content,reference,observation);
        }else{
            checkSupplemental(content,reference,observation);
        }
        return null;
    }

    private void checkCalendarId(Calendar content, SenateSiteCalendar reference, SpotCheckObservation<SpotcheckCalendarId> observation){
        checkString(content.getId().toString(),reference.getCalendarId().toString(),observation, SpotCheckMismatchType.CALENDAR_ID);
    }

    private void checkActiveList(Calendar content, SenateSiteCalendar reference, SpotCheckObservation<SpotcheckCalendarId> observation){
        List<CalendarEntry> calendarEntries = content.getActiveListMap().get(reference.getSequenceNo()).getEntries();
        List<CalendarEntry> refCalEntries = getCalEntry(reference);
        checkCollection(calendarEntries,refCalEntries,observation,SpotCheckMismatchType.ACTIVE_LIST_ENTRY);
    }

    private void checkSupplemental(Calendar content, SenateSiteCalendar reference, SpotCheckObservation<SpotcheckCalendarId> observation){
        List<CalendarEntry> calendarSupplementalEntries =
                content.getSupplemental(reference.getVersion()).getAllEntries()
                        .stream()
                        .map(calendarSupplementalEntry -> (CalendarEntry)calendarSupplementalEntry)
                        .collect(Collectors.toList());
        List<CalendarEntry> refCalendarSupplementalEntries = getCalEntry(reference);
        checkCollection(calendarSupplementalEntries,refCalendarSupplementalEntries,observation,SpotCheckMismatchType.SUPPLEMENTAL_ENTRY);
    }

    private List<CalendarEntry> getCalEntry(SenateSiteCalendar reference){
        List<Integer> billCalNumbers = reference.getBillCalNumbers();
        List<BillId> bill = reference.getBill();
        List<CalendarEntry> calendarEntries = new ArrayList<>();
        int i=0;
        for (Integer billcal :
                billCalNumbers) {
            calendarEntries.add(new CalendarEntry(billcal,bill.get(i)));
            i++;
        }
        return calendarEntries;
    }
}
