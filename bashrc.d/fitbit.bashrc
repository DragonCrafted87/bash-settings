#!/bin/bash

function fitbit-dev-start ()
{
    fitbit-os-simulator.bat &
    npx fitbit-build
    npx fitbit
}
