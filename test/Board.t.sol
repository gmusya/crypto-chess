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

    function test_ScholarsMate() public {
        Board board = new Board();
        board.MakeMove(Board.Cell(1, 4), Board.Cell(3, 4));

        assertEq(
            board.GetFEN(),
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
        );

        board.MakeMove(Board.Cell(6, 4), Board.Cell(4, 4));

        assertEq(
            board.GetFEN(),
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2"
        );

        board.MakeMove(Board.Cell(0, 5), Board.Cell(3, 2));

        assertEq(
            board.GetFEN(),
            "rnbqkbnr/pppp1ppp/8/4p3/2B1P3/8/PPPP1PPP/RNBQK1NR b KQkq - 1 2"
        );

        board.MakeMove(Board.Cell(7, 1), Board.Cell(5, 2));

        assertEq(
            board.GetFEN(),
            "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/8/PPPP1PPP/RNBQK1NR w KQkq - 2 3"
        );
    }
}
