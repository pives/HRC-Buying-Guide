<?php
//Authenticate Request
$pass="hrciphoneapp";
$salt="321524253";
$token=$_GET['key'];
if($token!=md5($pass . $salt)){
    die("Authentication Failed");
}
?>
