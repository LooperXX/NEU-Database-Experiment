<%--
  Created by IntelliJ IDEA.
  User: LooperXX
  Date: 2018/8/23
  Time: 15:42
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>银行代收费系统</title>
    <!--Import Google Icon Font-->
    <link href="http://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <!--Import materialize.css-->
    <link type="text/css" rel="stylesheet" href="css/materialize.min.css" media="screen,projection"/>
    <!--Import jQuery before materialize.js-->
    <script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
    <script type="text/javascript" src="js/materialize.min.js"></script>
    <!--Let browser know website is optimized for mobile-->
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <script type="text/javascript">
        $(document).ready(function () {
            $('.modal').modal();
            $('.parallax').parallax();
            $('select').material_select();
            $(".button-collapse").sideNav();
        });
    </script>
</head>
<body>
<header>
    <nav>
        <div class="nav-wrapper teal lighten-2">
            &nbsp;&nbsp;&nbsp;&nbsp;<a href="index.jsp" class="brand-logo"><i
                class="Medium material-icons">offline_bolt</i>银行代收费系统</a>
            <a href="#" data-activates="mobile-demo" class="button-collapse"><i class="material-icons">menu</i></a>
            <ul id="nav-mobile" class="right hide-on-med-and-down">
                <li><a href="#login"><i class="Medium material-icons left">person</i>登陆</a></li>
            </ul>
            <ul class="side-nav" id="mobile-demo">
                <li><a href="#login"><i class="Medium material-icons left">person</i>登陆</a></li>
            </ul>
        </div>
    </nav>
</header>

<div class="parallax-container">
    <div class="parallax"><img src="img/parallax1.jpg"></div>
</div>
<div class="section white">
    <div class="row container valign-wrapper center-align">
        <div class="col s2">
            <i class="Large material-icons">offline_bolt</i>
        </div>
        <div class="col s9">
            <h2 class="header">交电费?</h2>
            <div class="divider"></div>
            <h5>有我，就够了</h5>
            <div class="divider"></div>
        </div>
    </div>
</div>
<div class="parallax-container">
    <div class="parallax"><img src="img/parallax2.jpg"></div>
</div>
<div id="login" class="modal modal-fixed-footer ">
    <form method="post" action="login.jsp">
        <div class="modal-content">
            <div class="center-align">
                <img src="img/img_avatar.png" alt="Avatar" class="avatar" style="width: 20%;border-radius: 50%;">
            </div>
            <div class="row">
                <div class="input-field col s8 offset-s2">
                    <i class="material-icons prefix">account_circle</i>
                    <input id="text" name="text" type="number" class="validate" required="required" length="9">
                    <label for="text" data-error="输入用户ID长度超出设定" data-success="√">用户ID</label>
                </div>
            </div>
            <div class="row">
                <div class="input-field col s8 offset-s2">
                    <i class="material-icons prefix">lock</i>
                    <input id="password" name="psw" type="password" class="validate" required="required" length="20">
                    <label for="password" data-error="输入密码长度超出设定" data-success="√">密码</label>
                </div>
            </div>
            <div class="row">
                <div class="input-field col s8 offset-s2">
                    <select name="select">
                        <option value="" disabled selected>选择您的用户类型</option>
                        <option value="1" name="radio" selected>电力公司客户</option>
                        <option value="2" name="radio">电力公司抄表员</option>
                        <option value="3" name="radio">管理员</option>
                    </select>
                    <label>用户类型</label>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary modal-action modal-close waves-effect waves-green">关闭
            </button>
            <button type="submit" class="btn btn-secondary waves-effect waves-green">登陆</button>
        </div>
    </form>
</div>
</body>
</html>
