(function() {
    if (typeof jQuery == "function") {
        setTimeout(function () {
            $(document).on("click","#delete_user",function(e){
                debugger;
                e.preventDefault();
                var userId = $(this).attr("data-uid");
                $.ajax({
                    "url":"/users/"+userId,
                    "type":"DELETE",
                    success:function(result) {
                        if(result.success){
                            window.location = "/";
                        }
                    }
                });
            });


        }, 1000);
    }
})();