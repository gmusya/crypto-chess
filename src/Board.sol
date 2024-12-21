// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

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

    enum Color {
        kWhite,
        kBlack,
        kNothing
    }

    struct Cell {
        uint8 row;
        uint8 col;
    }

    // (row, column)
    Figure[8][8] public board;
    Color public whose_move;
    bool public white_kingside_castling_is_possible = true;
    bool public white_queenside_castling_is_possible = true;
    bool public black_kingside_castling_is_possible = true;
    bool public black_queenside_castling_is_possible = true;

    Cell public maybe_en_passant_cell; // (0, 0) if en-passant is impossible. A square over which a pawn has just passed while moving two squares otherwise
    uint32 public halfmove_clock; // the number of halfmoves since the last capture or pawn advance, used for the fifty-move rule
    uint32 public fullmove_number; // the number of the full moves

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

        whose_move = Color.kWhite;

        maybe_en_passant_cell.row = 0;
        maybe_en_passant_cell.col = 0;

        halfmove_clock = 0;
        fullmove_number = 1;
    }

    function CheckCellValidity(Cell memory cell) internal pure {
        require(
            0 <= cell.col && cell.col <= 7 && 0 <= cell.row && cell.row <= 7,
            "Invalid cell"
        );
    }

    function CellToColor(Cell memory cell) internal view returns (Color) {
        Figure figure = board[cell.row][cell.col];
        if (figure == Figure.kEmpty) {
            return Color.kNothing;
        }

        if (
            figure == Figure.kWhitePawn ||
            figure == Figure.kWhiteKnight ||
            figure == Figure.kWhiteBishop ||
            figure == Figure.kWhiteRook ||
            figure == Figure.kWhiteQueen ||
            figure == Figure.kWhiteKing
        ) {
            return Color.kWhite;
        }

        return Color.kBlack;
    }

    function IntToColumnCharacter(
        uint8 col
    ) internal pure returns (string memory) {
        if (col == 0) return "a";
        if (col == 1) return "b";
        if (col == 2) return "c";
        if (col == 3) return "d";
        if (col == 4) return "e";
        if (col == 5) return "f";
        if (col == 6) return "g";
        if (col == 7) return "h";

        revert("Unexpected column");
    }

    function CellToString(
        Cell memory cell
    ) internal pure returns (string memory) {
        CheckCellValidity(cell);

        string memory result = string.concat(
            IntToColumnCharacter(cell.col),
            Strings.toString(cell.row + 1)
        );

        return result;
    }

    function FigureToFENCharacter(
        Figure figure
    ) internal pure returns (string memory) {
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

    // https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation
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
                        FigureToFENCharacter(figure)
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

        if (whose_move == Color.kWhite) {
            result = string.concat(result, " w ");
        } else {
            result = string.concat(result, " b ");
        }

        bool at_least_one_characted_was_appended = false;
        if (white_kingside_castling_is_possible) {
            result = string.concat(result, "K");
            at_least_one_characted_was_appended = true;
        }
        if (white_queenside_castling_is_possible) {
            result = string.concat(result, "Q");
            at_least_one_characted_was_appended = true;
        }
        if (black_kingside_castling_is_possible) {
            result = string.concat(result, "k");
            at_least_one_characted_was_appended = true;
        }
        if (black_queenside_castling_is_possible) {
            result = string.concat(result, "q");
            at_least_one_characted_was_appended = true;
        }
        if (at_least_one_characted_was_appended) {
            result = string.concat(result, " ");
        }

        if (maybe_en_passant_cell.col != 0) {
            result = string.concat(
                result,
                CellToString(maybe_en_passant_cell),
                " "
            );
        } else {
            result = string.concat(result, "- ");
        }
        result = string.concat(result, Strings.toString(halfmove_clock), " ");
        result = string.concat(result, Strings.toString(fullmove_number));
        return result;
    }

    function abs(int8 x) private pure returns (int8) {
        return x >= 0 ? x : -x;
    }

    function IsMovePossibleOnEmptyBoardWhitePawn(
        Cell memory from,
        Cell memory to
    ) internal pure returns (bool) {
        if (from.col != to.col) {
            return
                abs(int8(from.col) - int8(to.col)) == 1 &&
                from.row + 1 == to.row;
        }
        return from.row + 1 == to.row || (from.row == 1 && to.row == 3);
    }

    function IsMovePossibleOnEmptyBoardBlackPawn(
        Cell memory from,
        Cell memory to
    ) internal pure returns (bool) {
        if (from.col != to.col) {
            return
                abs(int8(from.col) - int8(to.col)) == 1 &&
                from.row - 1 == to.row;
        }
        return from.row - 1 == to.row || (from.row == 6 && to.row == 4);
    }

    function IsMovePossibleOnEmptyBoardBishop(
        Cell memory from,
        Cell memory to
    ) internal pure returns (bool) {
        return
            abs(int8(from.row) - int8(to.row)) ==
            abs(int8(from.col) - int8(to.col));
    }

    function IsMovePossibleOnEmptyBoardRook(
        Cell memory from,
        Cell memory to
    ) internal pure returns (bool) {
        return from.row == to.row || from.col == to.col;
    }

    function IsMovePossibleOnEmptyBoardKing(
        Cell memory from,
        Cell memory to
    ) internal pure returns (bool) {
        return
            abs(int8(from.row) - int8(to.row)) <= 1 &&
            abs(int8(from.col) - int8(to.col)) <= 1;
    }

    function IsMovePossibleOnEmptyBoardQueen(
        Cell memory from,
        Cell memory to
    ) internal pure returns (bool) {
        return
            IsMovePossibleOnEmptyBoardBishop(from, to) ||
            IsMovePossibleOnEmptyBoardRook(from, to);
    }

    function IsMovePossibleOnEmptyBoardKnight(
        Cell memory from,
        Cell memory to
    ) internal pure returns (bool) {
        int8 diff1 = abs(int8(from.row) - int8(to.row));
        int8 diff2 = abs(int8(from.col) - int8(to.col));
        return (diff1 == 1 && diff2 == 2) || (diff1 == 2 && diff2 == 1);
    }

    function MakeWhitePawnMove(Cell memory from, Cell memory to) internal view {
        require(IsMovePossibleOnEmptyBoardWhitePawn(from, to));

        if (from.col == to.col) {
            for (uint8 r = from.row + 1; r <= to.row; ++r) {
                require(
                    CellToColor(Cell(r, from.col)) == Color.kNothing,
                    "Non-empty cell on pawn move"
                );
            }
        } else {
            Color to_color = CellToColor(to);
            require(to_color != Color.kNothing && to_color != whose_move);
        }
    }

    function MakeBlackPawnMove(Cell memory from, Cell memory to) internal view {
        require(IsMovePossibleOnEmptyBoardBlackPawn(from, to));

        if (from.col == to.col) {
            for (int8 r = int8(from.row) - 1; r >= int8(to.row); --r) {
                require(
                    CellToColor(Cell(uint8(r), from.col)) == Color.kNothing,
                    "Non-empty cell on pawn move"
                );
            }
        } else {
            Color to_color = CellToColor(to);
            require(to_color != Color.kNothing && to_color != whose_move);
        }
    }

    function MakeKnightMove(Cell memory from, Cell memory to) internal view {
        require(IsMovePossibleOnEmptyBoardKnight(from, to));
    }

    function MakeBishopMove(Cell memory from, Cell memory to) internal view {
        require(IsMovePossibleOnEmptyBoardBishop(from, to));

        int8 dcol = (from.col <= to.col) ? int8(1) : int8(-1);
        int8 drow = (from.row <= to.row) ? int8(1) : int8(-1);

        for (int8 s = 1; int8(from.col) + s * dcol != int8(to.col); ++s) {
            console.log('A');
            Cell memory inter_cell = Cell(uint8(int8(from.row) + s * drow), uint8(int8(from.col) + s * dcol));
            if (CellToColor(inter_cell) != Color.kNothing) {
                revert("Cannot pass through other piece");
            }
            console.log('B');
        }
    }

    function MakeRookMove(Cell memory from, Cell memory to) internal view {
        require(IsMovePossibleOnEmptyBoardRook(from, to));

        revert("Not implemented");
    }

    function MakeQueenMove(Cell memory from, Cell memory to) internal view {
        require(IsMovePossibleOnEmptyBoardQueen(from, to));

        revert("Not implemented");
    }

    function MakeKingMove(Cell memory from, Cell memory to) internal view {
        require(IsMovePossibleOnEmptyBoardKing(from, to));

        revert("Not implemented");
    }

    function CheckIfMovePossible(
        Cell memory from,
        Cell memory to
    ) internal view {
        CheckCellValidity(from);
        CheckCellValidity(to);

        require(CellToColor(from) == whose_move);
        require(CellToColor(to) != whose_move);

        Figure figure = board[from.row][from.col];
        if (figure == Figure.kWhitePawn) {
            console.log("White pawn move");
            MakeWhitePawnMove(from, to);
            return;
        }
        if (figure == Figure.kBlackPawn) {
            MakeBlackPawnMove(from, to);
            return;
        }
        if (figure == Figure.kWhiteKnight || figure == Figure.kBlackKnight) {
            MakeKnightMove(from, to);
            return;
        }
        if (figure == Figure.kWhiteBishop || figure == Figure.kBlackBishop) {
            MakeBishopMove(from, to);
            return;
        }
        if (figure == Figure.kWhiteRook || figure == Figure.kBlackRook) {
            MakeRookMove(from, to);
            return;
        }
        if (figure == Figure.kWhiteQueen || figure == Figure.kBlackQueen) {
            MakeQueenMove(from, to);
            return;
        }
        if (figure == Figure.kWhiteKing || figure == Figure.kBlackKing) {
            MakeKingMove(from, to);
            return;
        }

        require(false, "Unexpected figure");
    }

    function MakeMove(Cell memory from, Cell memory to) external {
        CheckIfMovePossible(from, to);

        Figure figure = board[from.row][from.col];

        bool is_capture = CellToColor(to) != Color.kNothing;
        bool is_pawn_move = figure == Figure.kWhitePawn ||
            figure == Figure.kBlackPawn;

        bool is_two_cells_pawn_move = (figure == Figure.kWhitePawn &&
            from.row == 1 &&
            to.row == 3) ||
            (figure == Figure.kBlackPawn && from.row == 6 && to.row == 4);

        board[to.row][to.col] = board[from.row][from.col];
        board[from.row][from.col] = Figure.kEmpty;

        halfmove_clock += 1;

        if (whose_move == Color.kWhite) {
            whose_move = Color.kBlack;
        } else {
            whose_move = Color.kWhite;
            fullmove_number += 1;
        }

        if (is_capture || is_pawn_move) {
            halfmove_clock = 0;
        }

        if (is_two_cells_pawn_move) {
            maybe_en_passant_cell.col = from.col;
            maybe_en_passant_cell.row = (from.row + to.row) / 2;
        } else {
            maybe_en_passant_cell.col = 0;
            maybe_en_passant_cell.row = 0;
        }
    }
}
