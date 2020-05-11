#! /bin/bash

##########################
# INIT
##########################

# the autograder directory
AG_DIR='/python_autograder'

# the parent directory containing everything about this grading job
export JOB_DIR='/grade'
# the job subdirectories
STUDENT_DIR=$JOB_DIR'/student'
TEST_DIR=$JOB_DIR'/tests'
OUT_DIR=$JOB_DIR'/results'

# where we will copy everything
export MERGE_DIR=$JOB_DIR'/run'

# now set up the stuff so that our run.sh can work
mkdir $MERGE_DIR
mkdir $OUT_DIR

mv $STUDENT_DIR/* $MERGE_DIR
mv $AG_DIR/* $MERGE_DIR
mv $TEST_DIR/* $MERGE_DIR

# user does not need a copy of this script
rm -f "$MERGE_DIR/run.sh"

# we need this to include code as python modules
touch $MERGE_DIR/__init__.py

# Do not allow ag user to modify, rename, or delete any existing files
chmod -R 755 "$MERGE_DIR"
chmod 1777 "$MERGE_DIR"

# Create directory without sticky bit for deletable files
export FILENAMES_DIR=$MERGE_DIR'/filenames'
mkdir $FILENAMES_DIR
chmod 777 $FILENAMES_DIR
mv ans.py setup_code.py test.py $FILENAMES_DIR

##########################
# RUN
##########################

echo "[run] starting autograder"

# randomly generate the name of the results file, so that someone can't guess and write to it
SECRET_NAME=$MERGE_DIR/`uuidgen`

# run the autograder as a limited user called ag
su -c "python3 $MERGE_DIR/pl_main.py $SECRET_NAME" ag

# remove any "fake" results.json files if they exist
rm -f $MERGE_DIR/results.json
rm -f $OUT_DIR/results.json

# copy the results file from secret if it exists
if [ -f "$SECRET_NAME" ]; then
  mv "$SECRET_NAME" $OUT_DIR/results.json
fi

# if that didn't work, then print a last-ditch message
if [ ! -s $OUT_DIR/results.json ]
then
  echo '{"succeeded": false, "score": 0.0, "message": "Your code could not be processed by the autograder. Please contact course staff and have them check the logs for this submission."}' > $OUT_DIR/results.json
fi

echo "[run] autograder completed"