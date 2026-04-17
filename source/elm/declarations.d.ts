namespace Main {
  const init = (options: { node?: HTMLElement | null; flags: Flags }) => ElmApp;
}

type Flags = unknown;

type ElmApp = {
  ports: {
    saveState: PortFromElm<string>;
    scrollTo: PortFromElm<string>;
    getViewport: PortFromElm<unknown>;
    gotViewport: PortToElm<unknown>;
    scrolledOverWorkPort: PortToElm<unknown>;
  };
};

type PortFromElm<Data> = {
  subscribe(callback: (fromElm: Data) => void): void;
};

type PortToElm<Data> = {
  send(data: Data): void;
};

// Don't know how to more specifically declare types for this one module, the
// obvious options didn't work.
// Ref: https://www.typescriptlang.org/docs/handbook/modules/reference.html
declare module "*/Main.elm" {
  export default Main;
}
