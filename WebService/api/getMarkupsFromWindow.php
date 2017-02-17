<?php
/**
 * Created by PhpStorm.
 * User: Nebul
 * Date: 12/11/2016
 * Time: 13:30
 */

//including the file dboperation
require_once '../includes/DbOperation.php';
ini_set('memory_limit', '3G');
//creating a response array to store data
$response = array();
$response['markups'] = array();
//if($_SERVER['REQUEST_METHOD']=='GET')
$x1 = $_GET['X1'];
$x2 = $_GET['X2'];
$y1 = $_GET['Y1'];
$y2 = $_GET['Y2'];

//$x1 = 37.0;
//$x2 = 40.0;
//$y1 = 19589.0;
//$y2 = 19590.0;

//creating object of class DbOperation
$db = new DbOperation();

//getting the teams using the function we created
$markups = $db->getMarkupsFromWindow($x1,$x2,$y1,$y2);
//$markups = $db->getMarkupsFromWindow();

//looping through all the teams.
while($markup = $markups->fetch_assoc()){
    //creating a temporary array
    $temp = array();

    //inserting the markup in the temporary array
    $temp['MARKUP_ID'] = $markup['MARKUP_ID'];
    $temp['POLYGON']=$markup['POLYGON'];
//    $temp['TURNINGS']=$markup['TURNINGS'];
//    $temp['ANGLES']=$markup['ANGLES'];
    $temp['CX']=$markup['CX'];
    $temp['CY']=$markup['CY'];

    //inserting the temporary array inside response
    array_push($response['markups'],$temp);
}

//displaying the array in json format
echo json_encode($response);