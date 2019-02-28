<%--
  Created by IntelliJ IDEA.
  User: LooperXX
  Date: 2018/8/28
  Time: 21:14
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% if(session.getAttribute("UID")==null || !session.getAttribute("UTYPE").equals("1"))//session has expired
    out.println("<script>window.location.href='"+"index.jsp"+"'</script>"); //redirect %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>银行代收费系统</title>
    <!--Import Google Icon Font-->
    <link href="http://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <!--Import materialize.css-->
    <link type="text/css" rel="stylesheet" href="css/materialize.min.css" media="screen,projection"/>
    <!--Let browser know website is optimized for mobile-->
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <!--Import jQuery before materialize.js-->
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript" src="js/materialize.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            uid = ${sessionScope.get("UID")};
            $( "#tab1" ).click(function () {
               query();
            });
            $( "#tab2" ).click(function () {
                query_card();
            });
            $( "#tab4" ).click(function () {
                query_balance();
            });
            $( "#tab5" ).click(function () {
                query_Pr();
            });
            $(".button-collapse").sideNav();
            $('.parallax').parallax();
            $('select').material_select();
            $('#form2').submit(function (e) {
                e.preventDefault();
                correct();
            });
        });
    </script>
</head>
<body>
<nav class="nav-extended teal lighten-2">
    <div class="nav-wrapper ">
        <a href="index.jsp" class="brand-logo center"><i
            class="Medium material-icons">offline_bolt</i>银行代收费系统</a>
        <a href="#" data-activates="mobile-demo" class="button-collapse"><i class="material-icons">menu</i></a>
        <ul id="nav-mobile" class="right hide-on-med-and-down">
            <li><a onclick="Materialize.toast('欢迎你，${sessionScope.get("UNAME")}', 4000)"><i class="material-icons left">room</i>欢迎用户 ${sessionScope.get("UNAME")}</a></li>
        </ul>
        <ul class="side-nav" id="mobile-demo">
            <li><a onclick="Materialize.toast('欢迎你，${sessionScope.get("UNAME")}', 4000)"><i class="material-icons left">room</i>欢迎用户 ${sessionScope.get("UNAME")}</a></li>
        </ul>
    </div>
    <div class="nav-content center">
        <ul class="tabs tabs-transparent">
            <li class="tab"><a id="tab1" class="active" href="#test1">查询欠费情况</a></li>
            <li class="tab"><a id="tab2" href="#test2">缴纳电费</a></li>
            <li class="tab"><a id="tab3" href="#test3">申请冲正</a></li>
            <li class="tab"><a id="tab4" href="#test4">查询余额</a></li>
            <li class="tab"><a id="tab5" href="#test5">查询电表清单</a></li>
        </ul>
    </div>
</nav>
<div id="test1" class="col s12">
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax1.jpg"></div>
    </div>
    <div class="section white container " id="section1" style="display: none">
    </div>
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax2.jpg"></div>
    </div>
</div>
<div id="test2" class="col s12">
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax1.jpg"></div>
    </div>
    <div class="section white container " id="section2" style="display: none">

    </div>
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax2.jpg"></div>
    </div>
</div>
<div id="test3" class="col s12">
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax1.jpg"></div>
    </div>
    <div class="section white container " id="section3">
        <form id="form2">
            <div class="row">
                <div class="col s3"></div>
                <div class="input-field col s6">
                    <i class="material-icons prefix active">assignment</i>
                    <input id="bt_id" type="number" length="9" class="validate" required="required">
                    <label for="bt_id" data-error="输入流水号超出设定" data-success="√" class="active">流水号</label>
                </div>
            </div>
            <div class="divider"></div>
            <br>
            <div class="center">
                <button type="submit" class="btn btn-secondary waves-effect waves-green center">提交</button>
            </div>
        </form>
    </div>
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax2.jpg"></div>
    </div>
</div>
<div id="test4" class="col s12">
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax1.jpg"></div>
    </div>
    <div class="section white container " id="section4">

    </div>
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax2.jpg"></div>
    </div>
</div>
<div id="test5" class="col s12">
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax1.jpg"></div>
    </div>
    <div class="section white" id="section5" style="padding-left:1%">

    </div>
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax2.jpg"></div>
    </div>
</div>
<script type="text/javascript">
    function query(){
        $.ajax({
            type : "POST",
            url : "Query_Servlet",
            dataType : "text",
            data : {'customer_id': uid},
            async : false,
            success : function(data) {
                var res = JSON.parse(data);
                console.log('data',res);
                if(!(res.type === "OK")){
                    console.log("您的输入有误:<");
                }else{
                    console.log("连上啦");

                    var line1_array = res.line1.split(";");
                    var line2_array = res.line2.split(",");
                    var line3_array = res.line3.split(";");
                    console.log("line1_array",line1_array);
                    console.log("line2_array",line1_array);
                    console.log("line3_array",line1_array);
                    var html = "";
                    html += "<div class=\"row\"><div class=\"col s1\"></div><table class=\"highlight col s10\">\n" +
                        "    <thead>\n" +
                        "    <tr>\n" +
                        "        <th>设备号</th>\n" +
                        "        <th>设备类型</th>\n" +
                        "        <th>客户编号</th>\n" +
                        "        <th>应缴日期</th>\n" +
                        "        <th>单月待缴金额</th>\n" +
                        "        <th>已缴费金额</th>\n" +
                        "        <th>剩余应缴</th>\n" +
                        "        <th>滞纳金</th>        \n" +
                        "    </tr>\n" +
                        "    </thead>\n" +
                        "    <tbody>";
                    var line1_array_;
                    for(var i = 0;i < line1_array.length - 1;i++){
                        line1_array_ = line1_array[i].split(",");
                        html +="    <tr>\n";
                        for(var j = 0;j < line1_array_.length;j++){
                            html += "<td>" + line1_array_[j] + " </td>\n";
                        }
                        html +="    </tr>";
                    }
                    html += "    </tbody>\n" +
                        "</table></div><div class=\"divider\"></div>";

                    html += "<div class=\"row\"><div class=\"col s3\"></div><table class=\"highlight col s6 offset-3\">\n" +
                        "    <thead>\n" +
                        "    <tr>\n" +
                        "        <th>客户编号</th>\n" +
                        "        <th>设备编号</th>\n" +
                        "        <th>总待缴金额</th>\n" +
                        "    </tr>\n" +
                        "    </thead>\n" +
                        "    <tbody>";

                    var line3_array_;
                    for(i = 0;i < line3_array.length - 1;i++){
                        line3_array_ = line3_array[i].split(",");
                        html +="    <tr>\n";
                        for(j = 0;j < line3_array_.length;j++){
                            html += "<td>" + line3_array_[j] + " </td>\n";
                        }
                        html +="    </tr>";
                    }
                    html += "    </tbody>\n" +
                        "</table></div><div class=\"divider\"></div>";

                    html += "<div class=\"row\"><div class=\"col s7\"></div><div class=\"col s5 \"><h5 class=\"header\">客户编号：" + line2_array[0] +
                        "&nbsp;&nbsp;&nbsp;&nbsp;总待缴金额：" + line2_array[1] + "</h5></div></div>";
                    $('#section1').html(html);
                    $('#section1').show();
                }
            },
            error : function() {
                console.log("服务器连接失败:<");
            }
        });
    }

    function query_card(){
        $.ajax({
            type : "POST",
            url : "PayFee_Servlet",
            dataType : "text",
            data : {'customer_id': uid,'type': '0'},
            async : false,
            success : function(data) {
                var res = JSON.parse(data);
                console.log('data',res);
                if(!(res.type === "OK")){
                    console.log("您的输入有误:<");
                }else{
                    console.log("连上啦");
                    var line1_array = res.line1.split(";");
                    card = line1_array;
                    console.log("line1_array",line1_array);
                    var html = "";
                    html += "<div class=\"row\"><div class=\"col s1\"></div><table class=\"highlight col s10\">\n" +
                        "    <thead>\n" +
                        "    <tr>\n" +
                        "        <th>银行ID</th>\n" +
                        "        <th>银行卡卡号</th>\n" +
                        "        <th></th>\n" +
                        "    </tr>\n" +
                        "    </thead>\n" +
                        "    <tbody>";
                    var line1_array_;
                    for(var i = 0;i < line1_array.length - 1;i++){
                        line1_array_ = line1_array[i].split(",");
                        html +="    <tr>\n";
                        for(var j = 0;j < line1_array_.length;j++){
                            html += "<td>" + line1_array_[j] + " </td>\n";
                        }
                        html += "<td><input name=\"group1\" type=\"radio\" value=\"" + i + "\" id=\"radio" + i + "\" />\n" +
                            "      <label for=\"radio" + i + "\"></label></td>\n";
                        html +="    </tr>";
                    }
                    html += "    </tbody>\n" +
                        "</table></div><div class=\"divider\"></div><br>";
                    html += "<div class=\"col s10 right-align\"><button class=\"btn waves-effect waves-light right-align\" onclick=\"query_device()\">下一步\n" +
                        "    <i class=\"material-icons right\">send</i>\n</div>" +
                        "  </button>";
                    $("#section2").html(html);
                    $("#radio0").attr("checked","checked");
                    $("#section2").show();
                }
            },
            error : function() {
                console.log("服务器连接失败:<");
            }
        });
    }

    function query_device(){
        var card_value = $("input[name='group1']:checked").val();
        if(card_value == null){
            alert("Error！");
        }else{
            var card_id = card[card_value].split(",")[1];
            $.ajax({
                type : "POST",
                url : "PayFee_Servlet",
                dataType : "text",
                data : {'customer_id': uid,'type': '1'},
                async : false,
                success : function(data) {
                    var res = JSON.parse(data);
                    console.log('data',res);
                    if(!(res.type === "OK")){
                        console.log("您的输入有误:<");
                    }else{
                        console.log("连上啦");
                        var line1_array = res.line1.split(";");
                        console.log("line1_array",line1_array);
                        var html = "";
                        html += "<div class=\"row\"><div class=\"col s1\"></div><table class=\"highlight col s10\">\n" +
                            "    <thead>\n" +
                            "    <tr>\n" +
                            "        <th>设备ID</th>\n" +
                            "        <th>设备地址</th>\n" +
                            "        <th></th>\n" +
                            "    </tr>\n" +
                            "    </thead>\n" +
                            "    <tbody>";
                        var line1_array_;
                        for(var i = 0;i < line1_array.length - 1;i++){
                            line1_array_ = line1_array[i].split(",");
                            html +="    <tr>\n";
                            for(var j = 0;j < line1_array_.length;j++){
                                html += "<td>" + line1_array_[j] + " </td>\n";
                            }
                            html += "<td><input name=\"group2\" type=\"radio\" value=\"" + line1_array_[0] + "\" id=\"radio_" + i + "\" />\n" +
                                "      <label for=\"radio_" + i + "\"></label></td>\n";
                            html +="    </tr>";
                        }
                        html += "    </tbody>\n" +
                            "</table></div><div class=\"divider\"></div><br>";
                        html += "<form id=\"form1\"><div class=\"row\">\n" +
                            "        <div class=\"input-field col s6\">\n" +
                            "          <i id=\"device_id_i\" class=\"material-icons prefix\">info</i>\n" +
                            "          <input id=\"device_id\" type=\"number\" length=\"9\" class=\"validate\"  required=\"required\">\n" +
                            "          <label id=\"device_id_label\" for=\"device_id\" data-error=\"输入设备ID超出设定\" data-success=\"√\" class=\"validate\">设备ID</label>\n" +
                            "        </div>\n" +
                            "        <div class=\"input-field col s6\">\n" +
                            "          <i class=\"material-icons prefix\">attach_money</i>\n" +
                            "          <input id=\"payFee\" type=\"number\"  step=\"0.01\" min=\"0.01\" max=\"1000.00\" class=\"validate\" required=\"required\" length=\"9\">\n" +
                            "          <label for=\"payFee\" data-error=\"输入缴费金额超出设定\" data-success=\"√\" class=\"\">缴费金额</label>\n" +
                            "        </div>\n" +
                            "      </div>";
                        html += "<div class=\"divider\"></div><br><div class=\"col s10 right-align\"><button class=\"btn waves-effect waves-light right-align\" type=\"submit\">下一步\n" +
                            "    <i class=\"material-icons right\">send</i>\n</div>" +
                            "  </button></form>";
                        $("#section2").html(html);
                        $("#radio_0").attr("checked","checked");
                        $("#device_id_i").addClass("active");
                        $("#device_id_label").attr("class","active");
                        $("#device_id").val($("input[name='group2']:checked").val());
                        $("input[name='group2']").click(function(){
                            $("#device_id").val($("input[name='group2']:checked").val());
                        });
                        $('#form1').submit(function (e) {
                            e.preventDefault();
                            pay_fee(card_id);
                        });
                    }
                },
                error : function() {
                    console.log("服务器连接失败:<");
                }
            });
        }
    }

    function pay_fee(card_id){
        console.log(uid,card_id,$("#device_id").val(),$("#payFee").val());
        $.ajax({
            type : "POST",
            url : "PayFee_Servlet",
            dataType : "text",
            data : {'customer_id': uid,'type': '2','card_id':card_id,'device_id': $("#device_id").val(),'in_fee':$("#payFee").val()},
            async : false,
            success : function(data) {
                var res = JSON.parse(data);
                console.log('data',res);
                if(!(res.type === "OK")){
                    console.log("您的输入有误:<");
                }else{
                    console.log("连上啦");
                    console.log(res.line1);
                    Materialize.toast(res.line1, 3000, 'rounded');
                    $("#tab1").click();
                }
            },
            error : function() {
                console.log("服务器连接失败:<");
            }
        });
    }

    function correct(){
        console.log($("#bt_id").val());
        $.ajax({
            type : "POST",
            url : "Correct_Servlet",
            dataType : "text",
            data : {'customer_id': uid,'BT_ID':$("#bt_id").val()},
            async : false,
            success : function(data) {
                var res = JSON.parse(data);
                console.log('data',res);
                if(!(res.type === "OK")){
                    console.log("您的输入有误:<");
                }else{
                    console.log("连上啦");
                    console.log(res.line1);
                    Materialize.toast(res.line1, 3000, 'rounded');
                    $("#tab1").click();
                }
            },
            error : function() {
                console.log("服务器连接失败:<");
            }
        });
    }

    function query_balance() {
        $.ajax({
            type : "POST",
            url : "Balance_Servlet",
            dataType : "text",
            data : {'customer_id': uid},
            async : false,
            success : function(data) {
                var res = JSON.parse(data);
                console.log('data',res);
                if(!(res.type === "OK")){
                    console.log("您的输入有误:<");
                }else{
                    console.log("连上啦");
                    var balance = JSON.parse(res.balance);
                    console.log(balance);
                    var html = "";
                    html += "<div class=\"row\"><div class=\"col s1\"></div><table class=\"highlight col s10\">\n" +
                        "    <thead>\n" +
                        "    <tr>\n" +
                        "        <th>余额记录ID</th>\n" +
                        "        <th>客户ID</th>\n" +
                        "        <th>余额变动类型</th>\n" +
                        "        <th>余额变化量</th>\n" +
                        "        <th>电表记录ID</th>\n" +
                        "        <th>缴费清单ID</th>\n" +
                        "        <th>银行流水号</th>\n" +
                        "        <th>变动时间</th>\n" +
                        "    </tr>\n" +
                        "    </thead>\n" +
                        "    <tbody>";
                    for(var i = 0; i < balance.length; i++){
                        html +="    <tr>\n";
                        for(var j = 0; j < balance[i].length; j++){
                            if(j === 2){
                                switch (balance[i][j]) {
                                    case "1":
                                        balance[i][j] = '增加';
                                        break;
                                    case "2":
                                        balance[i][j] = '减少';
                                        break;
                                    case "3":
                                        balance[i][j] = '冲正';
                                        break;
                                }
                                html += "<td>" + balance[i][j] + " </td>\n";
                            }else if (j === 4 || j === 5 || j === 6){
                                if(balance[i][j] == null)
                                    balance[i][j] = '#';
                                html += "<td>" + balance[i][j] + " </td>\n";
                            }else if(j === 7){
                                var date = new Date(balance[i][j]);
                                html += "<td>" + date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate() + ' ' + date.getHours() + ':' + date.getMinutes() + " </td>\n";
                            }else{
                                html += "<td>" + balance[i][j] + " </td>\n";
                            }
                        }
                        html +="    </tr>";
                    }
                    html += "    </tbody>\n" +
                        "</table></div><div class=\"divider\"></div><br>";
                    $("#section4").html(html);
                }
            },
            error : function() {
                console.log("服务器连接失败:<");
            }
        });
    }

    function query_Pr(){
        $.ajax({
            type : "POST",
            url : "List_Servlet",
            dataType : "text",
            data : {'customer_id': uid},
            async : false,
            success : function(data) {
                var res = JSON.parse(data);
                console.log('data',res);
                if(!(res.type === "OK")){
                    console.log("您的输入有误:<");
                }else{
                    console.log("连上啦");
                    var list = JSON.parse(res.list);
                    console.log(list);
                    var html = "";
                    html += "</div><table class=\"highlight col s12\">\n" +
                        "    <thead>\n" +
                        "    <tr>\n" +
                        "        <th>电费清单ID</th>\n" +
                        "        <th>设备ID</th>\n" +
                        "        <th>客户ID</th>\n" +
                        "        <th>抄表日期</th>\n" +
                        "        <th>上次读数</th>\n" +
                        "        <th>本次读数</th>\n" +
                        "        <th>基本费用</th>\n" +
                        "        <th>附加费用1</th>\n" +
                        "        <th>附加费用2</th>\n" +
                        "        <th>本金合计</th>\n" +
                        "        <th>实际合计</th>\n" +
                        "        <th>滞纳金</th>\n" +
                        "        <th>待缴日期</th>\n" +
                        "        <th>支付日期</th>\n" +
                        "        <th>已缴费用</th>\n" +
                        "        <th>支付状态</th>\n" +
                        "    </tr>\n" +
                        "    </thead>\n" +
                        "    <tbody>";
                    for(var i = 0; i < list.length; i++){
                        html +="    <tr>\n";
                        for(var j = 0; j < list[i].length; j++){
                            if(j === 13 && list[i][j] == null){
                                list[i][j] = '#';
                                html += "<td>" + list[i][j] + " </td>\n";
                            }else if(j === 3 || j === 12 || j === 13){
                                var date = new Date(list[i][j]);
                                html += "<td>" + date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate() + " </td>\n";
                            }else if(j === 15){
                                switch (list[i][j]) {
                                    case "0":
                                        list[i][j] = '未缴';
                                        break;
                                    case "1":
                                        list[i][j] = '已缴';
                                        break;
                                    case "2":
                                        list[i][j] = '待缴';
                                        break;
                                }
                                html += "<td>" + list[i][j] + " </td>\n";
                            }else{
                                html += "<td>" + list[i][j] + " </td>\n";
                            }
                        }
                        html +="    </tr>";
                    }
                    html += "    </tbody>\n" +
                        "</table></div><div class=\"divider\"></div><br>";
                    $("#section5").html(html);
                }
            },
            error : function() {
                console.log("服务器连接失败:<");
            }
        });
    }
</script>
</body>
</html>