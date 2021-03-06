import React from "react"
import PropTypes from "prop-types"
import { Link, useLocation } from "react-router-dom"



function NavLink(props) {

    const location = useLocation()

    const getClassString = (pathname) => {
        if ( pathname === props.link){
            return props.activeClassName ? props.activeClassName:
                ( props.className ? props.className: null)
        }
        return props.className ? props.className: null 
    }

    return (
        <Link className={getClassString(location.pathname)} to= { props.link }>
            {props.linkText}
        </Link>
    )
    
}


NavLink.propTypes = {
    className: PropTypes.string,
    activeClassName: PropTypes.string,
    linkText: PropTypes.string.isRequired,
    link: PropTypes.string.isRequired
}

export default NavLink