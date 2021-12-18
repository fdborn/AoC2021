import embed from 'vega-embed';

export const VegaLiteDisplay = {
  mounted() {
    const specScriptEl = this.el.querySelector('.vega-lite-spec')
    const spec = JSON.parse(specScriptEl.innerText);

    embed(this.el, spec, { actions: false }).then();
  }
}
