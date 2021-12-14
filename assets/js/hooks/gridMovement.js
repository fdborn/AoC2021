export const GridMovement = {
  mounted() {
    console.log(this);
    this.moves = JSON.parse(this.el.dataset.movesData);
    this.canvas = this.el.querySelector('canvas');
    this.context = this.canvas.getContext('2d');

    this.createGrid();
    this.renderGrid();
    this.renderCenter();
    this.renderDestination();
    this.renderMoves();
  },

  getMovesBounds() {
    const valuesByAxis = this.moves.reduce(({ x, y }, move) => ({
      x: [move[0], ...x],
      y: [move[1], ...y]
    }), { x: [], y: [] });

    const sorter = (a, b) => a - b;

    const sortedValues = {
      x: [...valuesByAxis.x].sort(sorter),
      y: [...valuesByAxis.y].sort(sorter)
    }

    return {
      x: {
        upper: sortedValues.x[sortedValues.x.length - 1],
        lower: sortedValues.x[0]
      },
      y: {
        upper: sortedValues.y[sortedValues.y.length - 1],
        lower: sortedValues.y[0]
      }
    }
  },

  renderGrid() {
    const width = this.canvas.width;
    const height = this.canvas.height;

    this.context.save();

    // Grid lines
    for (let column = 0; column < this.grid.size - 1; column++) {
      this.context.strokeStyle = 'rgba(0, 0, 0, 1)';
      this.context.lineWidth = 0.5;
      this.context.beginPath();
      this.context.moveTo((column + 1) * this.grid.cellSize, 0);
      this.context.lineTo((column + 1) * this.grid.cellSize, height);
      this.context.stroke();
    }

    for (let row = 0; row < this.grid.size - 1; row++) {
      this.context.strokeStyle = 'rgba(0, 0, 0, 1)';
      this.context.lineWidth = 0.5;
      this.context.beginPath();
      this.context.moveTo(0, (row + 1) * this.grid.cellSize);
      this.context.lineTo(width, (row + 1) * this.grid.cellSize);
      this.context.stroke();
    }

    this.context.restore();
  },

  renderCenter() {
    this.context.save();

    const centerCellPosition = this.grid.getCellPosition(0, 0);

    this.context.translate(centerCellPosition.x, centerCellPosition.y);
    this.context.fillStyle = 'rgba(255, 0, 0, 1)';
    this.context.fillRect(1, 1, this.grid.cellSize - 2, this.grid.cellSize - 2);

    this.context.restore();
  },

  renderDestination() {
    this.context.save();

    const lastMove = {
      x: this.moves[this.moves.length - 1][0],
      y: this.moves[this.moves.length - 1][1]
    }

    const lastCellPosition = this.grid.getCellPosition(lastMove.x, lastMove.y);

    console.log({lastMove, lastCellPosition});

    this.context.translate(lastCellPosition.x, lastCellPosition.y);
    this.context.fillStyle = 'rgba(0, 255, 0, 1)';
    this.context.fillRect(1, 1, this.grid.cellSize - 2, this.grid.cellSize - 2);

    this.context.restore();

  },

  renderMoves() {
    this.context.save();

    this.moves.reduce(({x: startX, y: startY}, [x, y]) => {
      const startPos = this.grid.getCellPosition(startX, startY);
      const endPos = this.grid.getCellPosition(x, y)
      this.context.strokeStyle = 'rgba(0, 0, 0, 1)';
      this.context.lineWidth = 2.5;
      this.context.beginPath();
      this.context.moveTo(startPos.x + (this.grid.cellSize / 2), startPos.y + (this.grid.cellSize / 2));
      this.context.lineTo(endPos.x + (this.grid.cellSize / 2), endPos.y + (this.grid.cellSize / 2));
      this.context.stroke();

      return {x, y};
    }, {x: 0, y: 0});

    this.context.restore();
  },

  createGrid(padding = 2) {
    const width = this.canvas.width;
    const height = this.canvas.width;
    const movesBounds = this.getMovesBounds();

    const gridBounds = {
      x: {
        upper: Math.max(0, movesBounds.x.upper) + 1 + padding,
        lower: Math.min(0, movesBounds.x.lower) - padding,
      },
      y: {
        upper: Math.max(0, movesBounds.y.upper) + 1 + padding,
        lower: Math.min(0, movesBounds.y.lower) - padding,
      }
    };

    const biggerAxis = (gridBounds.x.upper > gridBounds.y.upper ? gridBounds.x : gridBounds.y);

    const gridSize = biggerAxis.upper - biggerAxis.lower;

    const centerOffset = {
      x: Math.abs(gridBounds.x.lower),
      y: Math.abs(gridBounds.y.lower),
    };

    const longerSide = (width > height ? width : height);
    const cellSize = longerSide / gridSize;

    const getCellPosition = (x, y) => ({
      x: (x + centerOffset.x) * cellSize,
      y: (y + centerOffset.y) * cellSize,
    });

    this.grid = {
      bounds: gridBounds,
      size: gridSize,
      centerOffset,
      cellSize,
      getCellPosition,
    }
  }
}
