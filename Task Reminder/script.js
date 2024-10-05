// Initialize Speech Recognition
const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
const recognition = new SpeechRecognition();

recognition.onstart = function() {
    console.log("Listening...");
};

recognition.onresult = function(event) {
    const speechResult = event.results[0][0].transcript;
    console.log("Speech recognized: ", speechResult);
    document.getElementById('speechOutput').innerText = speechResult;

    // Proceed to process and extract date and details for calendar
    processSpeech(speechResult);
};

function startListening() {
    recognition.start();
}
function processSpeech(speechText) {
    // Use chrono to parse date and time from the speech
    const parsedDate = chrono.parseDate(speechText);

    if (parsedDate) {
        console.log("Parsed date/time: ", parsedDate);

        // Here, we will call a function to create a calendar event
        createCalendarEvent(speechText, parsedDate);
    } else {
        console.log("Could not find a date in the speech.");
    }
}
// Load and initialize the Google API client
function handleClientLoad() {
    gapi.load('client:auth2', initClient);
}

// Initialize the Google API client with Calendar scope
function initClient() {
    gapi.client.init({
        apiKey: "AIzaSyCLqzkdPeAZ2hd8gwYxvA-BpofOPOdJcks",  // Replace with your actual API key
        clientId: "952506383241-jt30hmpp5m20rb8kno08nntm3mi2cipj.apps.googleusercontent.com",  // Replace with your actual client ID
        discoveryDocs: ["https://www.googleapis.com/discovery/v1/apis/calendar/v3/rest"],
        scope: "https://www.googleapis.com/auth/calendar.events"
    }).then(function () {
        // Check login status
        checkLoginStatus();
    });
}

// Check if the user is signed in, or prompt login
function checkLoginStatus() {
    if (gapi.auth2.getAuthInstance().isSignedIn.get()) {
        console.log("User already signed in.");
    } else {
        gapi.auth2.getAuthInstance().signIn();
    }
}

function createCalendarEvent(eventDetails, eventDate) {
    // Ensure the event date is in IST (Indian Standard Time)
    const istTimeZone = 'Asia/Kolkata';  // Time zone identifier for IST

    const event = {
        'summary': 'Reminder',
        'description': eventDetails,
        'start': {
            'dateTime': eventDate.toISOString(),  // Use the parsed date
            'timeZone': istTimeZone  // Set time zone to IST
        },
        'end': {
            'dateTime': new Date(eventDate.getTime() + 60 * 60 * 1000).toISOString(),  // 1 hour later
            'timeZone': istTimeZone  // Set time zone to IST
        }
    };

    // Log the event object for debugging
    console.log("Creating event with data:", event);

    const request = gapi.client.calendar.events.insert({
        'calendarId': 'primary',  // Use 'primary' for the default calendar
        'resource': event
    });

    request.execute(function (event) {
        if (event.error) {
            console.error('Error creating event:', event.error);  // Log any API errors
            alert("Failed to create event. Please try again.");
        } else {
            console.log('Event created: ', event.htmlLink);
            alert("Event created successfully!");
        }
    });
}



// Load Google API on window load
window.onload = function () {
    handleClientLoad();
};


