export class LazyImgElement extends HTMLElement {
  connectedCallback(): void {
    if (this.getImg()) {
      return;
    }

    const src = this.getAttribute("src");

    if (!src) {
      throw new Error("LazyImgElement requires the `src` attribute");
    }

    this.attachShadow({ mode: "open" });

    const style = document.createElement("style");
    style.textContent = `
      img {
        width: 100%;
        height: 100%;
        opacity: 0;
      }

      img.loaded {
        animation-name: fade-in;
        animation-duration: 200ms;
        animation-timing-function: linear;
        animation-fill-mode: forwards;
      }

      @keyframes fade-in {
        from {
          opacity: 0;
        }
        to {
          opacity: 1;
        }
      }
      `;
    this.shadowRoot?.appendChild(style);

    const img = new Image();
    img.addEventListener("load", this.loadImage.bind(this));
    img.src = src;
    this.shadowRoot?.appendChild(img);

    this.loadImage();
  }

  loadImage(): void {
    const img = this.getImg();

    if (!img) {
      return;
    }

    if (img.complete) {
      this.onLoaded();
    }
  }

  onLoaded(): void {
    this.getImg()?.classList.add("loaded");
  }

  getImg(): HTMLImageElement | undefined {
    const img = this.shadowRoot?.querySelector("img");

    if (img instanceof HTMLImageElement) {
      return img;
    }

    return undefined;
  }
}
