function main_function() {
  console.log("Starting program ...");
  const vietnam_calendar_id = "ja.vietnamese#holiday@group.v.calendar.google.com";
  const indian_calendar_id = "ja.indian#holiday@group.v.calendar.google.com";

  // Check Vietnam Holidays
  get_holidays(vietnam_calendar_id, "ベトナム");
  // Check Indian Holidays
  get_holidays(indian_calendar_id, "インド");
}


function get_holidays(id, country) {
  var list = "";
  var s;

  // Provide Google Calendar ID
  s = listupEvent(id);
  // Message headings
  if (s != "")  list += `\n■${country}の休日\n${s}`;

  Logger.log(list);

  if (list != "") {
    Logger.log(`Found today is holiday of ${country}.`);
    var payload = {
      "text" : `おはようございます。\n本日${country}は休日です。\n${list}`,
      "channel" : "#company-info",
      // If you would like to overwrite Incoming Webhook default config,
      // should provide icon_url & username
      // "icon_url" : "http://XXXXXX/icon_neko.jpg",
      // "username" : "Global Holidays",
    }
    postSlack(payload);

  } else {
    Logger.log(`Found today is not holiday in ${country}`);
  }

}


function listupEvent(cal_id) {
  var list = "";
  var cal = CalendarApp.getCalendarById(cal_id);
  var events = cal.getEventsForDay(new Date());
  for(var i=0; i < events.length; i++){
    s = "";
    if (events[i].isAllDayEvent()) {
      s += Utilities.formatDate(events[i].getStartTime(),"GMT+0900","MM/dd  ");
    } else {
      s += Utilities.formatDate(events[i].getStartTime(),"GMT+0900","MM/dd HH:mm");
      s += Utilities.formatDate(events[i].getEndTime(), "GMT+0900","-HH:mm  ");
    }
    s += events[i].getTitle();
    Logger.log(s);

    list += s + "\n";
  }

  return list;
}


function postSlack(payload) {
  var options = {
    "method" : "POST",
    "payload" : JSON.stringify(payload)
  }
  // Slack Webhook URL
  var url = process.env('HOOK_URL');
  var response = UrlFetchApp.fetch(url, options);
  var content = response.getContentText("UTF-8");
}
