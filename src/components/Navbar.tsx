// src/components/Navbar.tsx
import { Link } from 'react-router-dom';
import { ConnectButton } from '@mysten/dapp-kit';

const Navbar = () => {
  return (
    <div className="navbar bg-base-100">
      <div className="navbar-start">
        <Link to="/" className="btn btn-ghost normal-case text-xl">
          PixelPawn
        </Link>
      </div>
      <div className="navbar-center">
        <Link to="/my-nfts" className="btn btn-ghost">
          My NFTs
        </Link>
        <Link to="/my-offers" className="btn btn-ghost">
          My Offers
        </Link>
        <Link to="/marketplace" className="btn btn-ghost">
          Marketplace
        </Link>
      </div>
      <div className="navbar-end">
        <ConnectButton />
      </div>
    </div>
  );
};

export default Navbar;