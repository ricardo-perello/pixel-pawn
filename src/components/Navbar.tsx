// components/Navbar.js
import { Link } from 'react-router-dom';
import { ConnectButton, useCurrentAccount } from "@mysten/dapp-kit";

const Navbar = () => {
  return (
    <div className="navbar bg-base-100 fixed top-0 z-50 h-20 mb-0 pb-0">
      <div className="navbar-start">
        <Link to="/" className="btn btn-ghost normal-case text-xl hover:scale-110 transition-transform duration-200">
          Pixel_Pawn
        </Link>
      </div>
      <div className="navbar-center">
        <ul className="menu menu-horizontal px-1 space-x-2">
          <li>
            <Link to="/" className="btn btn-base-100 text-lg normal-case hover:scale-110 transition-transform duration-200">Home</Link>
          </li>
          <li>            
          <Link to="/myNFTs" className="btn btn-base-100 text-lg normal-case hover:scale-110 transition-transform duration-200">My NFTs</Link>
          </li>
          <li>
            <Link to="/myOffers" className="btn btn-base-100 text-lg normal-case hover:scale-110 transition-transform duration-200">My Offers</Link>
          </li>
          <li>
            <Link to="/Test" className="btn btn-base-100 text-lg normal-case hover:scale-110 transition-transform duration-200">MarketPlace</Link>
          </li>
        </ul>
      </div>
      <div className="navbar-end">
        <ConnectButton />
      </div>
    </div>
  );
};

export default Navbar;
