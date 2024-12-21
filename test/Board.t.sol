// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Board} from "../src/Board.sol";

contract BoardTest is Test {
    function setUp() public {}

    function test_FEN() public {
        Board board = new Board();

        assertEq(
            board.GetFEN(),
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        );
    }

    function test_FirstMove() public {
        Board board = new Board();
        board.MakeMove(Board.Cell(1, 4), Board.Cell(3, 4));

        assertEq(
            board.GetFEN(),
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
        );
    }
}
