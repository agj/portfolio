/**
 * Element which invisibly loads an `<img>` with a provided `src` attribute,
 * and once it has fully loaded makes it smoothly appear with a transition
 * animation.
 */
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

    // The styles that make the image smoothly appear when loaded.
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

    // The `<img>` element that actually loads the image.
    const img = new Image();
    img.addEventListener("load", this.updateImageLoaded.bind(this));
    img.src = src;
    this.shadowRoot?.appendChild(img);

    this.updateImageLoaded();
  }

  /**
   * Checks if the image has loaded, and makes it visible if so.
   */
  updateImageLoaded(): void {
    const img = this.getImg();

    if (!img) {
      return;
    }

    if (img.complete) {
      img.classList.add("loaded");
    }
  }

  getImg(): HTMLImageElement | undefined {
    const img = this.shadowRoot?.querySelector("img");

    if (img instanceof HTMLImageElement) {
      return img;
    }

    return undefined;
  }
}
