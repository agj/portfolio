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
