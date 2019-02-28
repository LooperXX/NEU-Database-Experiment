<%--
  Created by IntelliJ IDEA.
  User: LooperXX
  Date: 2018/8/28
  Time: 21:15
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% if(session.getAttribute("UID")==null || !session.getAttribute("UTYPE").equals("3"))//session has expired
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
                check();
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
            <li><a onclick="Materialize.toast('欢迎你，${sessionScope.get("UNAME")}', 4000)"><i class="material-icons left">room</i>欢迎管理员 ${sessionScope.get("UNAME")}</a></li>
        </ul>
        <ul class="side-nav" id="mobile-demo">
            <li><a onclick="Materialize.toast('欢迎你，${sessionScope.get("UNAME")}', 4000)"><i class="material-icons left">room</i>欢迎管理员 ${sessionScope.get("UNAME")}</a></li>
        </ul>
    </div>
    <div class="nav-content">
        <ul class="tabs tabs-transparent">
            <li class="tab"><a id="tab1" class="active" href="#test1">对账</a></li>
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
                    <input id="bank_id" type="text" length="9" class="validate" required="required">
                    <label for="bank_id" data-error="输入银行ID超出设定" data-success="√">银行ID</label>
                </div>
            </div>
            <div class="row">
                <div class="col s3"></div>
                <div class="input-field col s6">
                    <i class="material-icons prefix">assignment</i>
                    <input id="check_date" type="text" class="datepicker" data-date-format="yyyy-mm-dd" required="required">
                    <label for="check_date">对账日期</label>
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
    function check(){
        var bank_id = $("#bank_id").val();
        var check_date = $("#check_date").val();
        console.log('bank_id',bank_id);
        console.log('check_date',check_date);
        $.ajax({
            type : "POST",
            url : "Check_Servlet",
            dataType : "text",
            data : {'customer_id': uid,'bank_id':bank_id,'check_date':check_date},
            async : false,
            success : function(data) {
                var res = JSON.parse(data);
                console.log('data',res);
                if(!(res.type === "OK")){
                    console.log("您的输入有误:<");
                }else{
                    console.log("连上啦");
                    console.log(res.line1);
                    if(res.line1 === "NO"){
                        Materialize.toast("[ERROR]您输入的日期或银行ID有误", 30000, 'rounded');
                    }else{
                        var line1_array = res.line1.split(";");
                        var html = $("#section1").html();
                        html += "<div class=\"row\"><div class=\"col s4\"></div><table class=\"highlight col s4\">\n" +
                            "    <thead>\n" +
                            "    <tr>\n" +
                            "        <th>银行总金额</th>\n" +
                            "        <th>银行总笔数</th>\n" +
                            "        <th></th>\n" +
                            "    </tr>\n" +
                            "    </thead>\n" +
                            "    <tbody>";
                        html +="    <tr>\n<td>" + line1_array[0] + "</td>\n<td>" + line1_array[1] + "</td>\n</tr>";
                        html += "    </tbody>\n" +
                            "</table></div><div class=\"divider\"></div><br>";
                        html += "<div class=\"row\"><div class=\"col s4\"></div><table class=\"highlight col s4\">\n" +
                            "    <thead>\n" +
                            "    <tr>\n" +
                            "        <th>公司总金额</th>\n" +
                            "        <th>公司总笔数</th>\n" +
                            "        <th></th>\n" +
                            "    </tr>\n" +
                            "    </thead>\n" +
                            "    <tbody>";
                        html +="    <tr>\n<td>" + line1_array[2] + "</td>\n<td>" + line1_array[3] + "</td>\n</tr>";
                        html += "    </tbody>\n" +
                            "</table></div><div class=\"divider\"></div><br>";
                        $("#section1").html(html);
                        if(line1_array[4] === '00'){
                            Materialize.toast(line1_array[5], 30000, 'rounded');
                        }else if(line1_array[4] === '01'){
                            for(var j = 5; j < line1_array.length - 1; j++){
                                Materialize.toast(line1_array[j], 30000, 'rounded');
                            }
                            $.ajax({
                                type : "POST",
                                url : "Detail_Servlet",
                                dataType : "text",
                                data : {'customer_id': uid,'bank_id':bank_id,'check_date':check_date},
                                async : false,
                                success : function(data) {
                                    var res = JSON.parse(data);
                                    console.log('data',res);
                                    if(!(res.type === "OK")){
                                        console.log("您的输入有误:<");
                                    }else{
                                        console.log("连上啦");
                                        console.log(res.line1);
                                        var line1_array = res.line1.split(";");
                                        var html = $("#section1").html();
                                        html += "<div class=\"row\"><div class=\"col s4\"></div><table class=\"highlight col s4\">\n" +
                                            "    <thead>\n" +
                                            "    <tr>\n" +
                                            "        <th>异常编号</th>\n" +
                                            "        <th>用户ID</th>\n" +
                                            "        <th>错误类型</th>\n" +
                                            "        <th>流水号</th>\n" +
                                            "        <th>缴费号</th>\n" +
                                            "    </tr>\n" +
                                            "    </thead>\n" +
                                            "    <tbody>";
                                        var line1_array_;
                                        for(var i = 0;i < line1_array.length - 1;i++){
                                            line1_array_ = line1_array[i].split(",");
                                            html +="    <tr>\n";
                                            for(var j = 0;j < line1_array_.length;j++){
                                                if(j === 2){
                                                    switch (line1_array_[j]) {
                                                        case "0":
                                                            line1_array_[j] = '银行缺失';
                                                            break;
                                                        case "1":
                                                            line1_array_[j] = '公司缺失';
                                                            break;
                                                        case "2":
                                                            line1_array_[j] = '冲正记录';
                                                            break;
                                                    }
                                                }
                                                html += "<td>" + line1_array_[j] + " </td>\n";
                                            }
                                            html +="    </tr>";
                                        }
                                        html += "    </tbody>\n" +
                                            "</table></div><div class=\"divider\"></div><br>";
                                        $("#section1").html(html);
                                    }
                                },
                                error : function() {
                                    console.log("服务器连接失败:<");
                                }
                            });
                        }else{
                            Materialize.toast('ERROR', 30000, 'rounded');
                        }
                    }
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
