// aeonform.js supports aeon requests

//----------------------------------------------------------------------
// Utility functions


function ClearAllCheckboxes() {
    $(':checkbox').prop('checked', false);
    selectedItems.clear();
}

function _RestoreSelectedCheckboxes() {
    selectedItems.forEach((identifier) => {
        let $inputEl = $(`input[name="Request"][value="${identifier}"]`);
        $inputEl.prop('checked', true);
        console.log("-- NAVIGATION al-contents", identifier, $inputEl.get(0));
    });
}

//----------------------------------------------------------------------
// Submit handler

function SubmitAeonRequestForm() {
    if (selectedItems.size == 0) {
        msg = `Please select one or more items to request.
(You may need to scroll down to see the checkboxes)`;
        alert(msg);
        return false;
    }

    // clean up old forms
    $(".aeon-submitted-form").remove();

    // clone the aeon request form to add the hidden inputs
    let $aeonForm = $("#EADRequestFormId").clone().attr('id', `EADRequestFormId-${(new Date).getTime()}`);
    $aeonForm.css({ display: 'none' }).addClass('aeon-submitted-form');
    selectedItems.forEach((identifier) => {
        let metaData = collectionItems.get(identifier);
        $('<input/>')
            .attr("type", "hidden")
            .attr("name", "Request")
            .attr("value", identifier)
            .appendTo($aeonForm);

        Object.keys(metaData).forEach((key) => {
            $('<input/>')
                .attr("type", "hidden")
                .attr("name", key)
                .attr("value", metaData[key])
                .appendTo($aeonForm);
        })
    })

    $("body").append($aeonForm);
    $aeonForm.submit();

    ClearAllCheckboxes();
    return false;
}

//----------------------------------------------------------------------
// Document ready set up

let selectedItems;
let collectionItems;

// collect the requeset metadata for each identifier
// so it can be submitted even if the checkbox is no longer
// being displayed
function _buildCollectionItemsMap() {
    $('input[type="checkbox"][name="Request"]').each(function (idx, inputEl) {
        let identifier = inputEl.value;
        let datum = {};
        let $labelEl = $(inputEl).parents('label');
        $labelEl.find('input').each(function (i, el) {
            let key = $(el).attr('name');
            if ( key.indexOf(identifier) >= 0 ) {
                let value = $(el).val();
                datum[key] = value;
            }
        })
        collectionItems.set(identifier, datum);
    })
}

document.addEventListener('DOMContentLoaded', function(event) {

    selectedItems = new Set();
    collectionItems = new Map();

    // listen for request checkbox selections on body
    $("body").on('click', 'input[type="checkbox"][name="Request"]', function (event) {
        let identifier = event.target.value;
        if ( ! collectionItems.get(identifier) ) {
            // either initial page load, or user has loaded
            // another page of checkboxes
            _buildCollectionItemsMap();
        }
        if ( event.target.checked ) {
            selectedItems.add(identifier);
        } else {
            selectedItems.delete(identifier);
        }
    })
})

document.addEventListener('turbolinks:load', function(event) {
    // user has switched collections; reset the data structures
    selectedItems.clear();
    collectionItems.clear();

    // contents has been paginated; restore any previously made selections
    $('.al-contents').on('navigation.contains.elements', _RestoreSelectedCheckboxes);
});
