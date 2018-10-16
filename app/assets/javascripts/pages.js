if(typeof jQuery == "function"){
    $(document).on('click',"#signInOutSwither",function(){
        $('#signupbox').show();
        $('#loginbox').hide();
    });
    $(document).on('click',"#signinlink",function () {
        $('#signupbox').hide();
        $('#loginbox').show();
    });
    $(document).on("change","#role_signup",function(){

        var d = $(this);
        var role = d.find("select").val();
        var option = $('option:selected', this);
        if(option.attr("data-hide")){
            $("#company_signup").hide();
        }else{
            $("#company_signup").show();
        }
    });
}