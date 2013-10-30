function repo_list($filter){
    $('#list-repos li a').each(function(index, repo){
	var re = new RegExp(".*" + $filter + ".*","i");
	if (!re.test($(repo).text())){
	    $(repo).slideUp();
	} else {
	    $(repo).slideDown();
	}
    })
}

$(document).ready(function(){
    //////////////////////////////////////////////////////////////////
    // LOAD CARTS BY DEFAULT
    repo_list('.*');

    //////////////////////////////////////////////////////////////////
    // INPUT EVENT HANDLERS
    $("#input-repo-list").on("input", null, null, repo_list_filter);
});


//////////////////////////////////////////////////////////////////
// CALLBACKS

function repo_list_filter() {
    var $list_filter = $('#input-repo-list').val();
    repo_list($list_filter);
}
