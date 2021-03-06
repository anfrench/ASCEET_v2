#' @title degrees to radians function
#'
#' @description Function converts decimal degrees to radians
#' @param ldeg Input decimal degrees. No default.
#' @keywords degrees
#' @export
#' @examples
#' deg2rad(32.1)

deg2rad <- function(ldeg) {
 ldeg*pi/180.0
}

#' radians to degrees function
#'
#' Function converts radians to decimal degrees
#' @param lrad Input radians. No default.
#' @keywords radians
#' @export
#' @examples
#' rad2deg(pi/2.0)

rad2deg <- function(lrad) {
  ldeg  <- lrad*180.0/pi
}

#' convert wind speed to 2m value function
#'
#' Function converts wind speed at measuremnt height to equivalent wind speed at 2m above the ground level
#' @param uz Wind speed in m/s. No default.
#' @param zw Wind speed measurement height in m. No default.
#' @keywords windspeed
#' @export
#' @examples
#' getu2f(1.5,3.0)

getu2f <- function(uz,zw) {
  #asce adjustment to 2m height for clipped grassed
  u2 <- uz*(4.87/(log(67.8*zw-5.42)))
  return(u2)
}


#' convert elevation to standard pressure
#'
#' Function converts site elevation to standardized pressure
#' @param uz Wind speed in m/s. No default.
#' @param zw Wind speed measurement height in m. No default.
#' @keywords windspeed
#' @export
#' @examples
#' getu2f(1.5,3.0)
elev2press <- function(z) {
  #standardized estimate of pressure at site in kPa
  preskp <- 101.3*((293.0-0.0065*z)/293.0)^5.26
  return(preskp)
}

#' convert site pressure to psychrometric constant
#'
#' Function converts site pressure to standardized psychrometric constant. Output in kPa.
#' @param P pressure in kPa. No default.
#' @keywords psychrometric
#' @export
#' @examples
#' press2psychro(98.1)

press2psychro <- function(P) {
  #standardized psychrometric constant in kPa/C
  gamma <- 0.000665*P
  return(gamma)
  
}

#' Compute slope of saturation vapor pressure curve
#'
#' Function calculates the slope of the saturation vapor pressure curve at the given air temperature. Input is Celsius. Output is kPa/C.
#' @param TC air temperature in celsius. No default.
#' @keywords Delta
#' @export
#' @examples
#' tcair2Delta(25.1)
tcair2Delta <- function(TC) {
  #slope of saturation vapor pressure curve kPa/C
  lterm <- TC+237.3
  Delta <- 2503.0*exp((17.27*TC)/lterm)/lterm^2
  return(Delta)
}

#' Compute saturation vapor pressure for H2O
#'
#' Function calculates saturation vapor pressure at the given air temperature. Input is Celsius. Output is kPa.
#' @param TC air temperature in celsius. No default.
#' @keywords esat
#' @export
#' @examples
#' tcair2esat(25.1)
tcair2esat <- function(TC) {
  #saturation vapor presss kPa
  esat <- 0.6108*exp(17.27*TC/(TC+237.3))
  return(esat)
}


#' Compute net shortwave radiation from incoming solar radiation
#'
#' Function calculates daily net shortwave radiation given incoming solar radiation. Input is MJ m^-2 d^-1. Output is MJ m^-2 d^-1.
#' @param Rs incoming solar radiation MJ m^-2 d^-1. No default.
#' @param albedo is surface albedo dimensionless. Default=0.23
#' @keywords esat
#' @export
#' @examples
#' Rsolar2Rns(29.6,0.22)

Rsolar2Rns <- function(Rs,albedo=0.23) {
  Rns <- (1.0-albedo)*Rs
  return(Rns)
}


#' Compute earth-sun distance factor
#'
#' Function calculates earth-sun distance factor. Input is day of year. Output is numeric factor dimensionless.
#' @param DOY day of year. No default.
#' @keywords earth-sun
#' @export
#' @examples
#' doy2dr(180)

doy2dr <- function(DOY) {
  #earth sun distance factor
  dr <- 1.0+0.033*cos(2.0*pi*DOY/365.0)
  return(dr)
}

#' Solar declination
#'
#' Function computes solar declination. Input day of year. Output radians.
#' @param DOY day of year. No default.
#' @keywords declination
#' @export
#' @examples
#' doy2delta(180)

doy2delta <- function(DOY) {
  #solar declination radians
  delta <- 0.409*sin((2.0*pi*DOY/365.0)-1.39)
  return(delta)
}


#' Sunset hour angle
#'
#' Function sunset hour angle from site latitude and solar declination. Input latitude in degrees but declination in radians. Output omega_s hours.
#' @param sitelatdeg latitude degrees. No default.
#' @param delta solar declination radians. Compute using doy2delta function.
#' @keywords sunset
#' @export
#' @examples
#' sunsethourangf(32.1,0.6)

sunsethourangf <- function(sitelatdeg,delta) {
  #sunset hour angle omega_s from site latitude and solar declination delta
  sitelatrad <- deg2rad(sitelatdeg)
  omega_s <- acos(-tan(sitelatrad)*tan(delta))
  return(omega_s)
}


#' Extraterrestrial radiation
#'
#' Function computes daily extraterrestrial radiation. Input earth-sun distance factor, sunset hour angle, site latitude in degrees, solar declination in radians. Output Ra in MJ m^-2 d^-1
#' @param dr earth-sun distance factor, inverse squared, dimensionless. No default.
#' @param omegas sunset hour angle radians, computed by sunsethourangf
#' @param sitelatdeg site location latitude decimal degrees
#' @param delta solar declination radians. Compute using doy2delta function.
#' @keywords extraterrestrial
#' @export
#' @examples
#' Radailyf(0.95,1.5,32.2.,0.6)

Radailyf <- function(dr,omegas,sitelatdeg,delta) {
  #extraterrestrial radiation  MY m^-2 d^-1
  Gsc <- 4.92 #MJ m^-2 h^-1 solar constant
  sitelatrad <- deg2rad(sitelatdeg)
  Ra <- (24.0/pi)*Gsc*dr*(omegas*sin(sitelatrad)*sin(delta)+cos(sitelatrad)*cos(delta)*sin(omegas))
  return(Ra)
}



#' Clear Sky radiation
#'
#' Function computes clear sky radiation at surface. Input extraterrestrial radiation obtained from Radailyf and station elevation in meters. Output Rso in MJ m^-2 d^-1
#' @param Ra extraterrestrial radiation MJ m^-2 d^-1. No default.
#' @param stationelevm meters. No default.
#' @keywords clear sky
#' @export
#' @examples
#' Ra2Rsof(23.0,312.2) 

Ra2Rsof <- function(Ra,stationelevm) {
  #simplified ASCE estimate of Rso lacking local calibration data
  Rso <- (0.75+2e-5*stationelevm)*Ra
  return(Rso)
} 

#' Cloudiness fraction
#'
#' Function computes cloudiness fraction function. Input Rs measured or calculated solar radiation, Rso calculated clear-sky radition. Output fc cloudiness function dimensionless
#' @param Rs solar radiation at surface MJ m^-2 d^-1. No default.
#' @param Rso clear-sky radiation ata surface MJ m^-2 d^-1. No default.
#' @keywords cloudiness
#' @export
#' @examples
#' getfcdf(23.0,25.0) 

getfcdf <- function(Rs,Rso) { #cloudiness fraction function
  fcd <- 1.35*(Rs/Rso)-0.35
  return(fcd)
}



#' Net Long-Wave Radiation
#'
#' Function computes net longwave radiation from cloudiness fraction, vapor pressure, daily air temperature range. Input fcd from getfcdf function, ea vapor pressure kPa, daily maximum and minimum air temperature in kelvin. Output Rnl MJ m^-2 d^-1
#' @param fcd Cloudiness fraction function dimensionless. No default.
#' @param ea Daily average vapor pressure kPa. No default.
#' @param tkmax Daily maximum air temperature K. No default.
#' @param tkmin Daily minimum air temperature K. No default.
#' @keywords Longwave
#' @export
#' @examples
#' getRnlf(0.1,1.5,300.0,291.0) 

getRnlf <- function(fcd,ea,tkmax,tkmin) {
  #ASCE net longwave radiation MJ m^-2 d^-1
  sigma <- 4.901e-9 #MJ K^-4 m^-2 d^-1
  Rnl <- sigma*fcd*(0.34-0.14*sqrt(ea))*((tkmax^4+tkmin^4)/2.0)
  return(Rnl)
}



#' Celsius to Kelvin 
#'
#' Function converts celsius to kelvin
#' @param tc temperature in celsius. No default.
#' @keywords celsius
#' @export
#' @examples
#' tc2tk(27.0)

tc2tk <- function(tc) {
  tc+273.15
}

#' Kelvin to Celsius 
#'
#' Function converts kelvin to celsius
#' @param tk temperature in kelvin. No default.
#' @keywords kelvin
#' @export
#' @examples
#' tk2tc(300.0)

tk2tc <- function(tk) {
  tk-273.15
}



#' Standardized ET
#'
#' Function computes ASCE Standardized ET
#' @param Rn Net radiation MJ m^-2 d^-1. No default.
#' @param G soil heat flux density MJ m^-2 d^-1. Default=0.0
#' @param T air temperature celsius
#' @param u2 wind speed at 2 m heigh m
#' @param es saturation vapor pressure kPa
#' @param ea mean actual vapor pressure kPa
#' @param Delta slope of saturation vapor pressure curve kPa C^-1
#' @param gamma psychrometric constant kPa C^-1
#' @param Cn numerator constant 900 for daily short crop 1600 for daily tall crop
#' @param Cd denominator constant 0.34 for daily short crop 0.38 for daily tall crop
#' @keywords ETsz
#' @export
#' @examples
#' ETszf(25.0,0.0,32.0,1.3,1.7,0.9,0.9,0.4,900,0.34)


ETszf <- function(Rn,G=0.0,T,u2,es,ea,Delta,gamma,Cn,Cd) {
  #ASCE standardized ET computation
  numer1 <- 0.408*Delta*(Rn-G)
  numer2 <- gamma*(Cn/(T+273.0))*u2*(es-ea)
  denom <- Delta+gamma*(1.0+Cd*u2)
  ETsz <- (numer1+numer2)/denom
  return(ETsz)
  
}

