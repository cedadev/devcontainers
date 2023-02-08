#!/bin/bash
#
# Runs the tests and keeps the results in a suitably named log file.
#
# e.g.  run_tests.sh rooki
#
# Does not source the setup script - you need to do this first.

package=$1

if [ -z "$package" ]; then echo "missing args"; exit 1 ; fi

outdir=/workspaces/test-logs
if [ ! -e $outdir ]; then mkdir -p $outdir; fi

cd /workspaces/$package || exit 1
outfile=$outdir/log_${package}_$(date +%Y%m%d.%H%M%S).log
python -m pytest tests 2>&1 | tee $outfile
status=$PIPESTATUS

if [ $status -eq 0 ]
then
    mv $outfile ${outfile}_succeeded
else
    mv $outfile ${outfile}_FAILED
fi

exit $status
