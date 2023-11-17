import React from "react";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";
import { Home, Menu, MessageCircle } from "lucide-react";
import { Button } from "./ui/button";

const Sidebar = () => {
  return (
    <div className="sidebar">
      <div className="sidebar-content">
        <div className="avatar-container">
          <Avatar className="avatar">
            <AvatarImage src="https://github.com/shadcn.png" />
            <AvatarFallback>User</AvatarFallback>
          </Avatar>
        </div>
        <div className="button-container">
          <Button className="button" variant="ghost">
            <Menu size={30} color="white" className="icon" />
          </Button>
        </div>
        <div className="button-container">
          <Button className="button" variant="ghost">
            <Home size={30} color="white" className="icon" />
          </Button>
        </div>
        <div className="button-container">
          <Button className="button" variant="ghost">
            <MessageCircle size={30} color="white" className="icon" />
          </Button>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;