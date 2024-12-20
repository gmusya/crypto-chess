// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Board {
    enum Figure {
        kEmpty,
        kWhitePawn,
        kWhiteKnight,
        kWhiteBishop,
        kWhiteRook,
        kWhiteQueen,
        kWhiteKing,
        kBlackPawn,
        kBlackKnight,
        kBlackBishop,
        kBlackRook,
        kBlackQueen,
        kBlackKing
    }

    // (row, column)
    Figure[8][8] public board;

    constructor() {
        for (uint8 c = 0; c <= 7; ++c) {
            board[1][c] = Figure.kWhitePawn;
            board[6][c] = Figure.kBlackPawn;
        }

        board[0][0] = Figure.kWhiteRook;
        board[0][1] = Figure.kWhiteKnight;
        board[0][2] = Figure.kWhiteBishop;
        board[0][3] = Figure.kWhiteQueen;
        board[0][4] = Figure.kWhiteKing;
        board[0][5] = Figure.kWhiteBishop;
        board[0][6] = Figure.kWhiteKnight;
        board[0][7] = Figure.kWhiteRook;

        board[7][0] = Figure.kBlackRook;
        board[7][1] = Figure.kBlackKnight;
        board[7][2] = Figure.kBlackBishop;
        board[7][3] = Figure.kBlackQueen;
        board[7][4] = Figure.kBlackKing;
        board[7][5] = Figure.kBlackBishop;
        board[7][6] = Figure.kBlackKnight;
        board[7][7] = Figure.kBlackRook;
    }

    function CellToFENCharacter(
        Figure figure
    ) external pure returns (string memory) {
        if (figure == Figure.kBlackPawn) return "p";
        if (figure == Figure.kBlackKnight) return "n";
        if (figure == Figure.kBlackBishop) return "b";
        if (figure == Figure.kBlackRook) return "r";
        if (figure == Figure.kBlackQueen) return "q";
        if (figure == Figure.kBlackKing) return "k";

        if (figure == Figure.kWhitePawn) return "P";
        if (figure == Figure.kWhiteKnight) return "N";
        if (figure == Figure.kWhiteBishop) return "B";
        if (figure == Figure.kWhiteRook) return "R";
        if (figure == Figure.kWhiteQueen) return "Q";
        if (figure == Figure.kWhiteKing) return "K";

        revert("Unexpected figure");
    }

    function GetFEN() external view returns (string memory) {
        string memory result = "";
        for (int8 row = 7; row >= 0; --row) {
            uint8 empty_cells = 0;
            for (int8 col = 0; col <= 7; ++col) {
                Figure figure = board[uint8(row)][uint8(col)];
                if (figure == Figure.kEmpty) {
                    empty_cells += 1;
                } else {
                    if (empty_cells >= 1) {
                        result = string.concat(
                            result,
                            Strings.toString(empty_cells)
                        );
                        empty_cells = 0;
                    }
                    result = string.concat(
                        result,
                        this.CellToFENCharacter(figure)
                    );
                }
            }
            if (empty_cells >= 1) {
                result = string.concat(result, Strings.toString(empty_cells));
            }
            if (row != 0) {
                result = string.concat(result, "/");
            }
        }
        return result;
    }
}
