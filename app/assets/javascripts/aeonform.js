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


//What validations to run depending on which page
function allValid(){
    if ( ValidateCheckboxes() && ValidateDateField()  ) {
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
        // $('#EADRequestFormId input').each(function(i, item) { console.log(item.name + ': ' + item.value)});
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


});

