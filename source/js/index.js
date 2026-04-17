import Main from "../elm/Main.elm";

const storedState = localStorage.getItem("portfolio-state");

const app = Main.init({
  node: document.getElementById("elm"),
  flags: {
    languages: window.navigator.languages
      ? window.navigator.languages
      : window.navigator.language
        ? [window.navigator.language]
        : [],
    viewport: {
      width: window.innerWidth,
      height: window.innerHeight,
    },
    storedState: storedState,
  },
});

app.ports.saveState.subscribe((state) => {
  localStorage.setItem("portfolio-state", state);
});

app.ports.getViewport.subscribe(() => {
  app.ports.gotViewport.send({
    width: document.body.clientWidth,
    height: document.body.clientHeight,
  });
});

app.ports.scrollTo.subscribe((targetId) => {
  setTimeout(() => {
    const el = document.getElementById(targetId);
    const targetPosition = Math.max(0, (el?.offsetTop ?? 0) - 30);
    window.scrollTo({ top: targetPosition, behavior: "smooth" });
  }, 0);
});

const throttle = (secs, fn) => {
  const waitTime = secs * 1000;
  let last = 0;
  return (...args) => {
    const now = Date.now();
    if (now > last + waitTime) {
      last = now;
      fn(...args);
    }
  };
};

document.addEventListener(
  "scroll",
  throttle(0.1, () => {
    const visibleWork = Array.from(document.querySelectorAll("div.work"))
      .map((element, index) => {
        const bounds = element.getBoundingClientRect();
        return {
          index,
          visibleArea:
            Math.min(bounds.bottom, document.documentElement.clientHeight) -
            Math.max(bounds.top, 0),
        };
      })
      .filter(({ visibleArea }) => visibleArea > 0)
      .reduce(
        (selected, current) =>
          current.visibleArea >= (selected?.visibleArea ?? 0)
            ? current
            : selected,
        { visibleArea: -1, index: null },
      );

    app.ports.scrolledOverWorkPort.send(visibleWork?.index);
  }),
);

class LazyImgElement extends HTMLElement {
  static get observedAttributes() {
    return ["src"];
  }

  connectedCallback() {
    if (this.getImg()) {
      return;
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
    this.shadowRoot.appendChild(style);

    const img = new Image();
    img.addEventListener("load", this.loadImage.bind(this));
    img.src = this.getAttribute("src");
    this.shadowRoot.appendChild(img);

    this.loadImage();
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue !== newValue) {
      this.loadImage();
    }
  }

  loadImage() {
    const img = this.getImg();

    if (!img) {
      return;
    }

    if (img.complete) {
      this.onLoaded();
    } else {
      img.classList.remove("loaded");
    }
  }

  onLoaded() {
    this.getImg()?.classList.add("loaded");
  }

  getImg() {
    return this.shadowRoot?.querySelector("img");
  }
}

customElements.define("lazy-img", LazyImgElement);
