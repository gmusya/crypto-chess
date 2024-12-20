// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Board} from "../src/Board.sol";

contract BoardTest is Test {
    Board public board;

    function setUp() public {
        board = new Board();
    }

    function test_FEN() public view {
        console.log(board.GetFEN());
        assertEq(board.GetFEN(), "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR");
    }
}
