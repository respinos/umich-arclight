// aeonform.js for use on both Aeon request page
// (text.components.xsl request button)  and Aeon confirmation
// page (AeonForm.xsl) form id=AeonRequestFormId

//----------------------------------------------------------------------
// Utility functions


function ClearAllCheckboxes() {
    $(':checkbox').prop('checked', false);
}

function SelectAllCheckboxes() {
    $(':checkbox').prop('checked', true);
}

function ClearItemCheckboxes() {
    $('input.item_request[type=checkbox]').prop('checked', false);
}

function SelectItemCheckboxes() {
    $('input.item_request[type=checkbox]').prop('checked', true);
}

// called by reset button in aeonform.xsl
function ReturnToMain() {
    var url = $('div#returntourl').html();
    window.location = url;
}

function isClementsConfirmationPage(){
    if ( $( "#ClementsConfirmationPageID").length){
        return true;
    }
    return false;
}


//----------------------------------------------------------------------
//Validation Functions

function ValidateDateField() {
    var valid = 1;

    // if not "Save for My Review" then enforce a date selection
    var id = $("#EADConfirmFormId input[type='radio']:checked").attr('id');
    if (id == 'VisitScheduled') {
        if ( $('input#datepicker').val() == '' ) {
            valid = 0;
        }
    } else if (id == 'UserReview') {
        $('input#datepicker').val('');
        $('input#request_duplication').prop('checked', false);
    }

    if (! valid) {
        var msg = "Please select a date for your visit."
        alert(msg);
    }

    return valid;
}

// Validate Checkboxes on Request or Confirmation page, depending on req parameter
function ValidateCheckboxes(req) {
    var valid = 0;
    var selection = 0;
    var selector = '';

    if (req) {
        selector = ':checkbox';
    } else {
        selector = 'input.item_request[type=checkbox]';
    }

    $(selector).each(function(i, elem) {
        if ( $(this).prop('checked') ) {
            selection = 1;
            valid = 1;
        }
    });

    var msg = "Please select one or more items to request."
    if (! selection) {
        if (req) {
            msg += " (You may need to scroll down to see the checkboxes)";
        }
        alert(msg);
    }

    return valid;
}

//for Clements
function ValidateResearchTopic() {
    var valid = 1;
    //XXX this looks wrong so comment out $( "#myselect" ).val();

    var ItemInfo3_val = $("#ItemInfo3").val()
    if (ItemInfo3_val == "Choose a Research Topic"){
        valid = 0;
    }
    // if not "Save for My Review" then enforce a date selection
    if (! valid) {
        var msg = "Please select a research topic from the list labeled: \"" + ItemInfo3_val +"\""
        alert(msg);
    }
    return valid;
}

//What validations to run depending on which page
function allValid(){
    // an element with the id "ClementsConfirmationPageID" must be present in the
    // HTML to trigger the additional validation of research topic
    if (isClementsConfirmationPage()){
        //add ValidateResearchTopic check for clements
        if ( ValidateCheckboxes() && ValidateDateField() && ValidateResearchTopic() ) {
            return true;
        }
    }
    else if ( ValidateCheckboxes() && ValidateDateField()  ) {
        return true;
    }
    else {
        return false;
    }
}

//----------------------------------------------------------------------

// For Aeon Request form (text.components.xsl) : construct additional inputs from checked checkedbox input and append to the form
function AddAeonRequestFormInputs(aform) {
    $('input[name=Request]').each(function () {
        if (this.checked) {
            // console.log($(this).val());
            var unique_id = $(this).val();

            // append Request input control
            $('<input/>')
                .attr("type", "hidden")
                .attr("name", "Request")
                .attr("value", unique_id)
                .appendTo(aform);

            $('input[type=hidden]').each(function(i, elem) {
                var name = elem.name;
                // console.log('unique_id='+unique_id+' name='+name);

                if (name.indexOf(unique_id) >= 0) {
                    var val = $(this).val();
                    // console.log('match:'+name);

                    // append associated input controls
                    $('<input/>')
                        .attr("type", "hidden")
                        .attr("name", name)
                        .attr("value", val)
                        .appendTo(aform);
                }
            });
        }
    });
}


// For Aeon Confirmation Form (aeonform.xsl): construct additional inputs from checked checkedbox input and append to the form
function AddAeonConfirmFormInputs(aform) {

    $('#aeon_fixed_fields').find('input').each(function(i, elem) {
        var name = $(this).attr("name");
        var val = $(this).val();
        // console.log('hidden input name='+name+' val='+val);

        // append common input controls
        $('<input/>')
            .attr("type", "hidden")
            .attr("name", name)
            .attr("value", val)
            .appendTo(aform);
    });

    $('input[type=checkbox]').each(function () {
        if (this.checked) {
            var unique_id = $(this).attr("id");
            // console.log("checkbox unique_id="+unique_id);

            $('div#'+unique_id).find('input').each(function(i, elem) {
                var name = $(this).attr("name");
                var val = $(this).val();
                //console.log('hidden input name='+name+' val='+val);

                // append associated input controls
                $('<input/>')
                    .attr("type", "hidden")
                    .attr("name", name)
                    .attr("value", val)
                    .appendTo(aform);
            });
        }
    });
}

//----------------------------------------------------------------------
//onSubmit logic


// Submit request from request button in first row of  ContentsList (text.components.xsl)

function SubmitAeonRequestForm() {
    if ( ValidateCheckboxes(1) ) {
        var aeon_form = $('#EADRequestFormId')[0];
        AddAeonRequestFormInputs(aeon_form);
        aeon_form.submit();
    }
}

// Submit request from Confirmation page
function SubmitAeonConfirmForm() {
    // If duplication request box checked ...
    if ( $('input#request_duplication').prop('checked') ) {
        $('input#request_duplication').attr("value", "Copy");
    }

    // Send aeon key/value for radios not "input name/value"
    var id = $("#EADConfirmFormId input[type='radio']:checked").attr('id');
    $('input#'+id).attr("name", id);
    $('input#'+id).attr("value", "Yes");



    if ( allValid() ) {
        //alert("all valid passed")
        var aeon_form = $('#EADConfirmFormId')[0];
        AddAeonConfirmFormInputs(aeon_form);
        aeon_form.submit();
    }
}
//----------------------------------------------------------------------
// Document ready set up

$(document).ready(function(){
    $('input[name=Visit]').click(function() {
        var id = $(this).attr('id');
        if (id == 'UserReview') {
            $('input#UserReview').prop("checked", true);
            $('input#VisitScheduled').prop("checked", false);
            $('div#scheduler_div').hide();
        } else {
            $('input#UserReview').prop("checked", false);
            $('input#VisitScheduled').prop("checked", true);
            $('div#scheduler_div').show();
        }
    });
    //XXX tbw If clements and browser supports localstorage, populate Research Topic from local storage
    if (isClementsConfirmationPage()){
        if (storageAvailable('localStorage')){
            populateResearchTopic();
        }
    }
    // When dropdown for ItemInfo3 changes, if clements and browser supports localstorage,
    // store new value

    $("#ItemInfo3").change(function(){
        var newValue =  $("#ItemInfo3").val()
        if (isClementsConfirmationPage()){
            if (storageAvailable('localStorage')){
                //alert("on change handler for ItemInfo3 called"+newValue);
                localStorage.setItem("topic", newValue);
            }
        }
    });
});


//----------------------------------------------------------------------
//Functions to support Clements Research Topic and local storage use

function populateResearchTopic(){
    //try to get topic from local storage
    // if there is one set the select to the correct value
    //   alert("populateResearchTopic needs code!");
    if ( localStorage.getItem("topic") ){
        var topic = localStorage.getItem("topic");
        //alert("topic is " + topic );
        //set select to topic
        $("#ItemInfo3").val(topic);
    }
}


//  storageAvailable function from "https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API"
function storageAvailable(type) {
    try {
        var storage = window[type],
            x = '__storage_test__';
        storage.setItem(x, x);
        storage.removeItem(x);
        return true;
    }
    catch(e) {
        return e instanceof DOMException && (
                // everything except Firefox
            e.code === 22 ||
            // Firefox
            e.code === 1014 ||
            // test name field too, because code might not be present
            // everything except Firefox
            e.name === 'QuotaExceededError' ||
            // Firefox
            e.name === 'NS_ERROR_DOM_QUOTA_REACHED') &&
            // acknowledge QuotaExceededError only if there's something already stored
            storage.length !== 0;
    }
}

