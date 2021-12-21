export const CountUp = {
  mounted() {
    this.counter = parseInt(this.el.dataset.start) || 0;
    this.el.textContent = this.counter;
    this.interval = setInterval(this.tick.bind(this), 1000);
  },

  destroyed() {
    clearInterval(this.interval);
  },

  tick() {
    this.counter += 1;
    this.el.textContent = this.counter;
  }
}
