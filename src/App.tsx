import { useEffect, useState } from 'react';
import './App.css';
import motokoLogo from './assets/motoko_moving.png';
import motokoShadowLogo from './assets/motoko_shadow.png';
import reactLogo from './assets/react.svg';
import viteLogo from './assets/vite.svg';
import{Button} from "../@/components/ui/button"
import { BrowserRouter as Router, Route, Link, Routes } from 'react-router-dom';
import { backend } from './declarations/backend';

import { HttpAgent, Actor } from '@dfinity/agent';

import { idlFactory } from './declarations/Delegate';
import { d } from 'vitest/dist/types-2b1c412e';

const localHost = 'http://localhost:3000/';
const agent = new HttpAgent({ host: localHost });

function App() {
  const [count, setCount] = useState<number | undefined>();
  const [loading, setLoading] = useState(false);
  const [delegates, setDelegates] = useState<any>();
  const [Allparties, setAllparties] = useState<string[] | undefined>(undefined);
  let delegateActor;

  // Get the current counter value
  const fetchCount = async () => {
    try {
      setLoading(true);
      const count = await backend.get();
      setCount(+count.toString()); // Convert BigInt to number
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // get delegtaes
  const getDelegates = async () => {
    try {
      setLoading(true);
      const delegates = await backend.getPartyDelegates('cpuo');
      console.log(delegates);
      setDelegates(delegates);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // voteForTeamParty
  const voteForTeamParty = async () => {
    try {
      setLoading(true);
      const delegates = await backend.voteForTeamParty('cpu');
      console.log(delegates);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // getAllParties

  const getAllParties = async () => {
    try {
      setLoading(true);
      const AllParties = await backend.getAllParties();
      console.log('', AllParties);
      return AllParties;
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // getPartyDelegates
  const getPartyDelegates = async () => {
    try {
      setLoading(true);
      const delegates = await backend.getPartyDelegates('cpu');
      console.log(delegates);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // load delegate information by thir principle id from  list of party delegates

  const getDelegateInfo = async () => {
    try {
      setLoading(true);
      const Allparties = await getAllParties();
      console.log('all parties', Allparties);
      setAllparties(Allparties);
      
      // for each party in AllParties, get the party
      // for each party get party delegates
      // for each party delegate get the delegate info
      // return delegate info as a list
      if (!Allparties) return;
     
      
      const DelegateDetailsPromises = Allparties.map(async (party) => {
        const DelegatesFromparty = await backend.getPartyDelegates(party);
        console.log('delegates from party', DelegatesFromparty);
      
        // loop the DelegatesFromparty return delegate canister id
        const DelegateIdPromises = DelegatesFromparty.map(async (id) => {
          delegateActor = await Actor.createActor(idlFactory, {
            agent,
            canisterId: id,
          });
      
          const postName = await delegateActor.getPostHolder();
          const delegateowner = await delegateActor.getDelegateName();
          const imageData = await delegateActor.getImageAsset();
          const PartyName = await delegateActor.getTeamNaming();
          const ImageContent = new Uint8Array(imageData);
          //turn imgage content to actual image Url
          const image = URL.createObjectURL(
            new Blob([ImageContent.buffer], { type: 'image/png' }),
          );
      
          // return list  of  postNmae, delegateowner, image, PartyName
          console.log('post name',postName, delegateowner, image, PartyName);
      
          return [postName, delegateowner, image, PartyName,id,party];
        });
      
        const DelegateIds = await Promise.all(DelegateIdPromises);
        console.log('delegate ids', DelegateIds);
        return DelegateIds;
      });
      
      const DelegateDetails = await Promise.all(DelegateDetailsPromises);
      console.log('delegate details', DelegateDetails);
    
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const increment = async () => {
    if (loading) return; // Cancel if waiting for a new count
    try {
      setLoading(true);
      await backend.inc(); // Increment the count by 1
      await fetchCount(); // Fetch the new count
    } finally {
      setLoading(false);
    }
  };

  // reset the count
  const reset = async () => {
    if (loading) return; // Cancel if waiting for a new count
    try {
      setLoading(true);
      await backend.reset(); // Reset the count to 0
      await fetchCount(); // Fetch the new count
    } finally {
      setLoading(false);
    }
  };

  // Fetch the count on page load
  useEffect(() => {
    fetchCount();
  }, []);

  return (
    // <div className="App">
    //   <div className=' bg-red-600'>
    //     <a href="https://vitejs.dev" target="_blank">
    //       <img src={viteLogo} className="logo vite" alt="Vite logo" />
    //     </a>
    //     <a href="https://reactjs.org" target="_blank">
    //       <img src={reactLogo} className="logo react" alt="React logo" />
    //     </a>
    //     <a
    //       href="https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/motoko/"
    //       target="_blank"
    //     >
    //       <span className="logo-stack">
    //         <img
    //           src={motokoShadowLogo}
    //           className="logo motoko-shadow"
    //           alt="Motoko logo"
    //         />
    //         <img src={motokoLogo} className="logo motoko" alt="Motoko logo" />
    //       </span>
    //     </a>
    //   </div>
    //   <h1>Vite + React + Motoko</h1>
    //   <div className="card">
    //     <button onClick={increment} style={{ opacity: loading ? 0.5 : 1 }}>
    //       count is {count}
    //     </button>
    //     <button onClick={reset} style={{ opacity: loading ? 0.5 : 1 }}>
    //       reset
    //     </button>

    //     <button onClick={getDelegates} style={{ opacity: loading ? 0.5 : 1 }}>
    //       get cpu deletes
    //     </button>

    //     <button onClick={getAllParties} style={{ opacity: loading ? 0.5 : 1 }}>
    //       list of parties
    //     </button>

    //     <button
    //       onClick={getPartyDelegates}
    //       style={{ opacity: loading ? 0.5 : 1 }}
    //     >
    //       get party delegates
    //     </button>

    //     <button
    //       onClick={getDelegateInfo}
    //       style={{ opacity: loading ? 0.5 : 1 }}
    //     >
    //       getDelegateInfo
    //     </button>

    //     <p>
    //       Edit <code>backend/Backend.mo</code> and save to test HMR
    //     </p>
    //   </div>
    //   <p className="read-the-docs">
    //     Click on the Vite, React, and Motoko logos to learn more
    //   </p>
    // </div>

    // <Router>
    //   <SideBar/>
    //   <Routes>
    //     <Route path='/' element={<Home/>}/>

       

        
    //   </Routes>

      

    // </Router>
    <div>
    <Button>Click me</Button>
    <h1 className="text-3xl font-bold underline text-black flex justify-center items-center">
    Hello world!
  </h1>
  </div>

  
  );
}

export default App;
