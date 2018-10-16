(function(){
    if(typeof jQuery == "function") {
        setTimeout(function() {
            if ($("#isViewingOwnHouse").html()) {
                // debugger;

                $.ajaxSetup({
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    }
                });

                $.ajax({
                    "url": "/interests/h",
                    "type": "POST",
                    "data": {
                        "id": JSON.parse($("#houseId").html())
                    },
                    success: function (result) {
                        if (result.success && result.users.length > 0) {
                            $("#interests_carousel").removeClass("hide");

                            for (var i in result.users) {
                                user = result.users[i];
                                cloneDiv = $("#interest_users_template").clone().attr("id", "");
                                cloneDiv.find("h5").html(user.name);
                                cloneDiv.find("span").html(user.contact);
                                cloneDiv.attr("data-href", user.url);
                                cloneDiv.on("click", function () {
                                    window.location = $(this).attr("data-href");
                                });
                                cloneDiv.appendTo($("#interests_carousel"));
                            }
                            $("#interest_users_template").remove();
                            $(".interest_carousel_heading").removeClass("hide");
                            $('.owl-carousel').owlCarousel({
                                loop: true,
                                margin: 10,
                                nav: true,
                                dots: true,
                                items: 4
                            })
                        }
                    },
                    complete: function () {
                        $("#isViewingOwnHouse").parent().remove();
                    }
                });

                $.ajax({
                    "url": "/inquiries/h",
                    "type": "POST",
                    "data": {
                        "id": JSON.parse($("#houseId").html())
                    },
                    success: function (result) {
                        if (result.success && result.inquiries.length) {
                            $("#inquiries_section").removeClass("hide");

                            var inquiryTemplateReplacer = function (inquiry) {
                                var template = $("#inquiry_template");
                                template.find("h5").find("strong").html(inquiry.name);
                                template.find(".contact").html(inquiry.contact);
                                template.find(".subject").html(inquiry.subject);
                                template.find("p").html(inquiry.message);
                                template.find("button").attr("data-inquiryid", inquiry.id);
                                if (inquiry.hasOwnProperty("reply")) {
                                    template.find(".reply").removeClass("hide").find("span").html(inquiry.reply);
                                    template.find(".reply_box").addClass("hide");
                                } else {
                                    template.find(".reply").addClass("hide");
                                    template.find(".reply_box").removeClass("hide");
                                }
                            };

                            if (result.inquiries.length) {
                                if (result.inquiries.length == 1) {
                                    $(".inq_prev").remove();
                                    $(".inq_next").remove();
                                }
                                var inquiries = result.inquiries;
                                var no_of_inq = inquiries.length;
                                var current_index = 0;
                                $(".inq_prev").addClass("hide");
                                inquiryTemplateReplacer(inquiries[current_index]);
                                $(".inq_prev").on('click', function () {
                                    current_index--;
                                    $(".inq_next").removeClass("hide");
                                    if (current_index == 0) {
                                        $(this).addClass("hide");
                                    }
                                    inquiryTemplateReplacer(inquiries[current_index]);
                                });
                                $(".inq_next").on('click', function () {
                                    current_index++;
                                    $(".inq_prev").removeClass("hide");
                                    if (current_index == no_of_inq - 1) {
                                        $(this).addClass("hide");
                                    }
                                    inquiryTemplateReplacer(inquiries[current_index]);
                                });

                                $(".inquiry_reply").on("click", function (e) {
                                    e.preventDefault();
                                    var inquiryId = $(this).attr("data-inquiryid");
                                    var textarea = $(".reply_box");
                                    var self = $(this);
                                    $.ajax({
                                        "url":"/inquiries/"+inquiryId,
                                        "type":"PUT",
                                        "data":{
                                            "reply":textarea.val()
                                        },
                                        "success":function(result){
                                            if(result.success){
                                                $("#inquiries_section").find(".reply").show().removeClass("hide").find("span").html(textarea.val());
                                                self.remove();
                                                textarea.remove();
                                            }
                                        }
                                    });
                                });

                            }

                        }
                    }
                });

                //
                // result = {
                //     "success": true,
                //     "inquiries": []
                // };
                // result = {
                //     "success": true,
                //     "inquiries": [
                //         {
                //             "name": "Tester",
                //             "contact": "Abc@rediff.com",
                //             "subject": "AAA FA JJLF LAF",
                //             "message": "Hi use whatsapp and go home",
                //             "id": 2
                //         }
                //     ]
                // };
                // result = {
                //     "success": true,
                //     "inquiries": [
                //         {
                //             "name": "Teste AI r",
                //             "contact": "Abc@re22diff.com",
                //             "subject": "AAA Inq ONE",
                //             "message": "Hi one person use whatsapp and go home",
                //             "id": 1
                //         },
                //         {
                //             "name": "Tester",
                //             "contact": "Abc@rediff.com",
                //             "subject": "AAA FA JJLF LAF",
                //             "message": "Hi use whatsapp and go home",
                //             "id": 2
                //         },
                //         {
                //             "name": "Teste111r",
                //             "contact": "amnfm2@rediff.com",
                //             "subject": "AAA phaad FA JJLF LAF",
                //             "message": "Hi dont  whatsapp and go class",
                //             "id": 3,
                //             "reply": "My reply"
                //         }
                //     ]
                // };
                //
                //

            }

            $("#house_filter").on("submit", function (e) {
                e.preventDefault();
                var inputs = $(this).find("input");
                var selects = $(this).find("select");
                var filters = {};
                for (var i in selects) {
                    if (i == "length") {
                        break;
                    }
                    var select = $(selects[i]);
                    var alphabet = select.attr("name");
                    var val = select.val();
                    if (val != -1) {
                        filters[alphabet] = val;
                    }
                }

                for (var i in inputs) {
                    if (i == "length") {
                        break;
                    }
                    var input = $(inputs[i]);
                    var name = input.attr("name");
                    if (i % 2 == 0) {
                        var filterName = name.replace("_min", "");
                    } else {
                        // min
                        var filterName = name.replace("_max", "");
                    }
                    if (filters.hasOwnProperty(filterName)) {
                        var val = input.val();
                        if (val != -1 && val.length) {
                            filters[filterName].push(input.val());
                        }
                    } else {
                        if (input.val().length) {
                            filters[filterName] = [input.val()];
                        } else {
                            filters[filterName] = [];
                        }
                    }
                }

                $.each(filters, function (key, value) {
                    if (value.length == 0) {
                        delete filters[key];
                    }
                });

                $.ajax({
                    "url": "/searchFilter",
                    "type": "POST",
                    "data": filters,
                    "success": function (result) {
                        window.location = result.url;

                    }
                })
            });


            $(".snb_card").on("click", function () {
                var href = $(this).attr("data-href");
                var win = window.open(href, '_blank');
                win.focus();
            });


            var role_selector = $($("#edit_user").find("select")[0]);
            var company_selector = $("#edit_user").find(".field");
            company_selector = $(company_selector[company_selector.length - 1]);
            role_selector.on("change", function () {
                var new_value = $(this).val();
                if (new_value == 1) {
                    company_selector.hide();
                } else {
                    company_selector.show();
                }
            });
        },2000);


                $(document).on("click", "#interestCta", function (e) {
                    e.preventDefault();
                    var houseId = $(this).attr('data-hid');
                    if (!$.parseJSON($(this).attr("data-done"))) {
                        var self = $(this);
                        $.ajax({
                            'url': '/interests',
                            'type': 'POST',
                            'data': {
                                "interest": {
                                    'house_id': houseId
                                }
                            },
                            'success': function (response) {
                                var success = response.success;
                                var interestMessage = response.message;
                                //self.remove();

                                self.attr("data-done", true);
                                if (success) {
                                    self.parent().siblings(".successCta").show();
                                    self.parent().siblings(".failCta").html("").hide();
                                    $("#inq_form").removeClass("hide");
                                } else {
                                    self.parent().siblings(".failCta").html(interestMessage.user_id).show();
                                    self.parent().siblings(".successCta").html("").hide();
                                }
                            }
                        });
                    }
                });

                $(document).on("click", ".create_inq", function (e) {
                    e.preventDefault();
                    var subject = $("#inq_form").find("input").val();
                    var message = $("#inq_form").find("textarea").val();
                    if (subject.length == 0 || message == 0) {

                    } else {
                        var houseId = $(this).attr("data-hid");
                        $.ajax({
                            "url": "/inquiries",
                            "type": "POST",
                            "data": {
                                house_id: houseId,
                                subject: subject,
                                message: message
                            },
                            success: function (result) {
                                var success = result.success;

                                $("#inq_form").remove();
                                $("#inq_msg").removeClass("hide");
                            },
                            error: function (result) {
                                // assume success

                            },
                            failure: function (result) {
                                // $("#inq_form").html("Your inquiry is successful");

                            }
                        });
                    }
                });

                $(document).on('click', "#removeHouse", function (e) {
                    e.preventDefault();
                    var houseId = $(this).attr('data-hid');
                    $.ajax({
                        'url': '/houses/' + houseId,
                        'type': 'DELETE',
                        'success': function () {
                            window.location = "/houses";
                            alert("House is removed successfully");
                            window.location = "/houses"
                        },
                        'error': function (message) {
                            alert(message);

                        }
                    })
                });

                $(document).on("submit", "#searchForm", function (e) {
                    e.preventDefault();
                    var keyword = $(this).find("input").val();
                    if (keyword.length) {
                        $.ajax({
                            'url': '/search',
                            'type': 'POST',
                            'data': $(this).serialize(),
                            'success': function (response) {
                                window.location = response.url
                            },
                            'error': function (message) {
                                alert(message);

                            }
                        });
                    }
                });


        }

})();