# My Customer Übersich widgets

Create desktop widgets with React.
Download widgets made by others [here](https://tracesof.net/uebersicht-widgets/)



Example widget
```js
  export const command = "echo Hello World!"

  export const refreshFrequency = 5000 // ms

  export const render = ({ output }) => (
    <h1>{output}</h1>
  )

  export const className = `
    left: 20px
    top: 20px
    color: #fff
  `
```
