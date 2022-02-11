import logo from './logo.svg';
import './App.css';
import React, { Component } from 'react';
const envProps = require('./env');


class App extends Component {

  constructor(props) {
    super();
    this.state = {
      node: "NODE",
      namespace: "NAMESPACE",
      pod: "POD",
      cpu: 0,
      ram: 0,
    }
    this.loadData = this.loadData.bind(this)
  }

  componentDidMount() {
    this.loadData()
    setInterval(this.loadData, 300);
  }

  async loadData() {
    try {
      const url = envProps.API_HOST + ":" + envProps.API_PORT + "/stats";
      const res = await fetch(url);
      const blocks = await res.json();
      const ram = blocks.ram;
      const cpu = blocks.cpu;
      const pod = blocks.pod;
      const node = blocks.node;
      const namespace = blocks.namespace;
      console.log(url,node,namespace,pod,ram,cpu);
      this.setState({
        node, namespace, pod, cpu, ram
      })
    } catch (e) {
      console.log(e);
    }
  }


  render() {
    return (
      <div className="App" >
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <div>
            <h2>NODE : {this.state.node} </h2>
            <h3>POD : {this.state.namespace}/{this.state.pod}</h3>
            <h4>CPU : {this.state.cpu}</h4>
            <h4>RAM : {this.state.ram}</h4>
          </div>
        </header>
      </div>
    );
  }
}
export default App;
