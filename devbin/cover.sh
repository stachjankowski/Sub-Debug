#!/bin/bash

find t/ -type f -exec perl -MDevel::Cover {} \; && cover