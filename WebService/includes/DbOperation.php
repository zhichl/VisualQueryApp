<?php

/**
 * Created by PhpStorm.
 * User: Nebul
 * Date: 04/11/2016
 * Time: 16:53
 */
class DbOperation
{
    private $conn;

    //Constructor
    function __construct()
    {
        require_once dirname(__FILE__) . '/Config.php';
        require_once dirname(__FILE__) . '/DbConnect.php';
        // opening db connection
        $db = new DbConnect();
        $this->conn = $db->connect();
    }

    //Function to create a new user
//    public function createTeam($name, $memberCount)
//    {
//        $stmt = $this->conn->prepare("INSERT INTO team(name, member) values(?, ?)");
//        $stmt->bind_param("si", $name, $memberCount);
//        $result = $stmt->execute();
//        $stmt->close();
//        if ($result) {
//            return true;
//        } else {
//            return false;
//        }
//    }


    public function getAllMarkups(){
//        $stmt = $this->conn->prepare("SELECT * FROM markup");
        $stmt = $this->conn->prepare("SELECT * FROM markup LIMIT 500000");
        $stmt->execute();
        $result = $stmt->get_result();
        return $result;
    }

    public function getMarkupsInRange($offset, $range){
//        $stmt = $this->conn->prepare("SELECT * FROM markup");
        $stmt = $this->conn->prepare("SELECT * FROM markup LIMIT ?, ?");
        $stmt->bind_param('dd', $offset, $range);
        $stmt->execute();
        $result = $stmt->get_result();
        return $result;
    }

    public function getMarkupsFromWindow($x1, $x2, $y1, $y2){
        $stmt = $this->conn->prepare("select * from markup where cx between ? and ? and cy between ? and ?");
        $stmt->bind_param('dddd', $x1, $x2, $y1, $y2);
        $stmt->execute();
        $result = $stmt->get_result();
        return $result;
    }
//    public function getMarkupsFromWindow(){
//        $stmt = $this->conn->prepare("select * from markup where CX between 37.0 and 40.0 and CY between 19589.0 and 19590.0");
////        $stmt->bind_param('dddd', $x1, $x2, $y1, $y2);
//        $stmt->execute();
//        $result = $stmt->get_result();
//        return $result;
//    }

}