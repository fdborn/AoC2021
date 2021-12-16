import embed from 'vega-embed';

export const VegaLiteDisplay = {
  mounted() {
    const spec = JSON.parse(this.el.dataset.spec);

    embed(this.el, spec, { actions: false }).then();
  }
}
