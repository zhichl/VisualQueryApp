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

//creating a key in the response array to insert values
//this key will store an array iteself
$response['markups'] = array();

//creating object of class DbOperation
$db = new DbOperation();

//getting the markups using the function created
$markups = $db->getAllMarkups();

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
