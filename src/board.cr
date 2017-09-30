require "./environment"

class Board
  property board : Array(Int32)

  def initialize(@board : Array(Int32) = [0] * 16)
  end

  def initialize(b : Board)
    @board = b.board.clone
  end

  def ==(b : Board)
    board == b.board
  end

  def ==(b : Array(Int32))
    board == b
  end

  def [](tile_number)
    @board[tile_number]
  end

  def [](row, col)
    self.[(row << 2) + col]
  end

  def []=(tile_number, value)
    @board[tile_number] = value
  end

  def []=(row, col, value)
    self.[(row << 2) + col] = value
  end

  def transpose!
    4.times do |row|
      row.times do |col|
        self.[row, col], self.[col, row] = self.[col, row], self.[row, col]
      end
    end
  end

  def another_transpose!
    4.times do |i|
      (3 - i).times do |j|
        self[i, j], self[3 - j, 3 - i] = self[3 - j, 3 - i], self[i, j]
      end
    end
  end

  def reflect_horizonal!
    0.upto(3) do |row|
      self.[row, 0], self.[row, 3] = self.[row, 3], self.[row, 0]
      self.[row, 1], self.[row, 2] = self.[row, 2], self.[row, 1]
    end
  end

  def reflect_vertical!
    0.upto(3) do |col|
      self.[0, col], self.[3, col] = self.[3, col], self.[0, col]
      self.[1, col], self.[2, col] = self.[2, col], self.[1, col]
    end
  end

  def rotate_right!
    temp_board = Board.new self
    0.upto(3) do |row|
      0.upto(3) do |col|
        self.[row, col] = temp_board[3 - col, row]
      end
    end
  end

  def rotate_left!
    temp_board = Board.new self
    0.upto(3) do |row|
      0.upto(3) do |col|
        self.[row, col] = temp_board[col, 3 - row]
      end
    end
  end

  def move!(opcode)
    case opcode
    when 3
      move_left!
    when 1
      move_right!
    when 0
      move_up!
    when 2
      move_down!
    else
      -1
    end
  end

  def to_s(io)
    0.upto(15) do |tile_number|
      print self.[tile_number]
      print "\t"
      if tile_number % 4 == 3
        puts ""
      end 
    end
  end

  def move_left!
    changed = false
    score = 0

    4.times do |r|
      i = 0

      1.upto(3) do |j|
        next if self[r, j] == 0

        if self[r, i] != 0
          while (i + 1) < j && self[r, i + 1] != 0
            i += 1
          end

          x = self[r, i]
          y = self[r, j]

          if (x - y).abs == 1 || (x == y == 1)
            self[r, i], self[r, j] = Math.max(x, y) + 1, 0
            score += TILE_MAPPING[self[r, i]]
            i += 1
            changed = true
          elsif self[r, i + 1] == 0
            i += 1
            self[r, i], self[r, j] = self[r, j], 0
            changed = true
          end
        else
          self[r, i], self[r, j] = self[r, j], 0
          changed = true
        end
      end
    end

    changed ? score : -1
  end

  def move_right!
    reflect_horizonal!
    score = move_left!
    reflect_horizonal!
    score
  end

  def move_up!
    transpose!
    score = move_left!
    transpose!
    score
  end

  def move_down!
    another_transpose!
    score = move_left!
    another_transpose!
    score
  end

  def can_move_left?
    4.times do |r|
      i = 0

      1.upto(3) do |j|
        next if self[r, j] == 0

        if self[r, i] != 0
          while (i + 1) < j && self[r, i + 1] != 0
            i += 1
          end

          x = self[r, i]
          y = self[r, j]

          if (x - y).abs == 1 || (x == y == 1)
            return true
          elsif self[r, i + 1] == 0
            return true
          end
        else
          return true
        end
      end
    end

    false
  end

  def can_move?(opcode)
    case opcode
    when 3
      can_move_left?
    when 1
      can_move_right?
    when 0
      can_move_top?
    when 2
      can_move_down?
    else
      -1
    end
  end

  def can_move_right?
    reflect_horizonal!
    flag = can_move_left?
    reflect_horizonal!
    flag
  end

  def can_move_top?
    transpose!
    flag = can_move_left?
    transpose!
    flag
  end

  def can_move_down?
    another_transpose!
    flag = can_move_left?
    another_transpose!
    flag
  end
end
