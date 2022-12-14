<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://www.springframework.org/tags" prefix="sp" %>
<div class="it-header-wrapper" tabindex="-1">
    <header class="it-header-slim-wrapper p-0" data-testid="Header">
        <div class="container-fluid" style="font-weight: 600">
            <div class="row">
                <div class="col-12 mb-0 px-xl-3">
                    <div class="it-header-slim-wrapper-content">
                        <div class="d-lg-block navbar-brand normal-breack-text">
                            <div class="row"><a
                                    aria-label="Vai al sito del Dipartimento per la trasformazione digitale"
                                    href="https://innovazione.gov.it/dipartimento/"><u>Dipartimento per la
                                trasformazione digitale</u></a><span class="mr-1 ml-sm-1 ml-0"> e </span><a
                                    aria-label="Vai al sito dell'Istat"
                                    href="https://www.istat.it/"><u>Istat</u></a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="it-header-center-wrapper py-3 header-h">
            <div class="container-fluid px-lg-2">
                <div class="row">
                    <div class="col-12">
                        <div class="it-header-center-content-wrapper">
                            <div class="it-brand-wrapper"><a class="focus-element"
                                                             aria-label="(s schema il catalogo nazionale della semantica dei dati) - Vai alla home"
                                                             href="${conf.getHomeUrl()}">
                                <div class="row mx-0">
                                    <div class="col-md-2">
                                        <svg width="78" height="78" viewBox="0 0 64 73"
                                             xmlns="http://www.w3.org/2000/svg"
                                             class="img-fluid img-logo-header-normal d-inline-block align-top p-1 rounded"
                                             alt="" title="Home">
                                            <g fill="none" fill-rule="evenodd">
                                                <path fill="#FFF" d="M0 6h64v64H0z"></path>
                                                <text font-family="TitilliumWeb-Bold, Titillium Web" font-size="48"
                                                      font-weight="bold" letter-spacing="-1.2" fill="#06C">
                                                    <tspan x="26" y="54">S</tspan>
                                                </text>
                                                <circle fill="#06C" cx="17.5" cy="27.5" r="4.5"></circle>
                                            </g>
                                        </svg>
                                    </div>
                                    <div class="col-md-10">
                                        <div class="it-brand-text"><h2 class="h3">Schema</h2>
                                            <h3 style="color: white; text-transform: unset">Il catalogo nazionale della
                                                semantica dei dati</h3>
                                        </div>
                                    </div>
                                </div>
                            </a></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </header>
</div>
