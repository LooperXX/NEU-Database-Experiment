<%--
  Created by IntelliJ IDEA.
  User: LooperXX
  Date: 2018/8/28
  Time: 21:14
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% if(session.getAttribute("UID")==null || !session.getAttribute("UTYPE").equals("2"))//session has expired
    out.println("<script>window.location.href='"+"index.jsp"+"'</script>"); //redirect %>
<html>
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
            $(".button-collapse").sideNav();
            $('.parallax').parallax();
            $('#form1').submit(function (e) {
                e.preventDefault();
                meter_log();
            });
            $('.datepicker').pickadate({
                format: 'yyyy-mm-dd',
                selectMonths: true, // Creates a dropdown to control month
                selectYears: 15 // Creates a dropdown of 15 years to control year
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
            <li><a onclick="Materialize.toast('欢迎你，${sessionScope.get("UNAME")}', 4000)"><i class="material-icons left">room</i>欢迎抄表员 ${sessionScope.get("UNAME")}</a></li>
        </ul>
        <ul class="side-nav" id="mobile-demo">
            <li><a onclick="Materialize.toast('欢迎你，${sessionScope.get("UNAME")}', 4000)"><i class="material-icons left">room</i>欢迎抄表员 ${sessionScope.get("UNAME")}</a></li>
        </ul>
    </div>
    <div class="nav-content">
        <ul class="tabs tabs-transparent">
            <li class="tab"><a id="tab1" class="active" href="#test1">抄表</a></li>
        </ul>
    </div>
</nav>
<div id="test1" class="col s12">
    <div class="parallax-container">
        <div class="parallax"><img src="img/parallax1.jpg"></div>
    </div>
    <div class="section white container " id="section1">
        <form id="form1">
            <div class="row">
                <div class="col s3"></div>
                <div class="input-field col s6">
                    <i class="material-icons prefix">assignment</i>
                    <input id="device_id" type="number" length="9" class="validate" required="required">
                    <label for="device_id" data-error="输入设备号超出设定" data-success="√">设备号</label>
                </div>
            </div>
            <div class="row">
                <div class="col s3"></div>
                <div class="input-field col s6">
                    <i class="material-icons prefix">assignment</i>
                    <input id="mt_number" type="number" length="9" class="validate" required="required">
                    <label for="mt_number" data-error="输入电表读数超出设定" data-success="√">电表读数</label>
                </div>
                <div class="col s3"></div>
            </div>
            <div class="row">
                <div class="col s3"></div>
                <div class="input-field col s6">
                    <i class="material-icons prefix">assignment</i>
                    <input id="mt_date" type="text" class="datepicker" data-date-format="yyyy-mm-dd" required="required">
                    <label for="mt_date">抄表日期</label>
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
<script type="text/javascript">
    function meter_log(){
        var device_id = $("#device_id").val();
        var mt_number = $("#mt_number").val();
        var mt_date = $("#mt_date").val();
        console.log('device_id',device_id);
        console.log('mt_number',mt_number);
        console.log('mt_date',mt_date);
        $.ajax({
            type : "POST",
            url : "Meter_Servlet",
            dataType : "text",
            data : {'customer_id': uid,'device_id':device_id,'mt_number':mt_number,'mt_date':mt_date},
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
