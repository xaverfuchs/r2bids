% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/B006Data.R
\docType{data}
\name{B006Data}
\alias{B006Data}
\title{Data from the Experiment B006}
\format{
A data frame with 32455 rows and 30 variables:
\describe{
\item{Participant}{Participant identifier}
\item{Run}{Experiment run (e.g., 'Run1', 'Run2')}
\item{Posture}{Posture of the trial (e.g., 'uncrossed')}
\item{StimSide}{Side of the stimulus (e.g., 'same', 'different')}
\item{StimSegment}{Segment of the arm where the stimulus was applied}
\item{Tactor1}{First tactor number}
\item{Tactor2}{Second tactor number}
\item{Tactor1Side}{Side of the first tactor (e.g., 'left', 'right')}
\item{Tactor1Segment}{Segment of the arm for the first tactor}
\item{Tactor2Side}{Side of the second tactor (e.g., 'left', 'right')}
\item{Tactor2Segment}{Segment of the arm for the second tactor}
\item{Stim1Intens}{Intensity of the first stimulus}
\item{Stim2Intens}{Intensity of the second stimulus}
\item{Trialtype}{Type of the trial}
\item{SOA}{Stimulus Onset Asynchrony (interval between stimuli)}
\item{Repetition}{Repetition count}
\item{Trialnumber}{Number of the trial}
\item{TimeAfterBeep}{Time after the beep (timing indicator)}
\item{Response}{Participant's response}
\item{Response_meaning}{Meaning of the response}
\item{Response_correct}{Whether the response was correct}
\item{RT}{Reaction time in milliseconds}
\item{Order}{Order of the trial}
\item{ResponseCoding}{Coding of the response}
\item{Trial_ok}{Whether the trial was valid}
\item{Trial_repeated}{Whether the trial was repeated}
\item{Age}{Age of the participant}
\item{Sex}{Sex of the participant (e.g., 'male', 'female', 'other')}
\item{Arm_top}{The arm that was on top in the crossed condition}
\item{Length_lower_arm}{Length of the participant's lower arm in centimeters}
}
}
\source{
Data collected in a behavioral neuroscience experiment at Tobias Heed's Reach and Touch Lab.
}
\usage{
B006Data
}
\description{
These data are from an experiment on touch perception in humans that applied the so-called Limb Identification Task.
In each trial, participants receive two stimuli that were either on the same arm or on two different arms and decided
by lifting either their heels or toes whether they were on the same or on different limbs. Of interest is
a limb crossing effect in this task, i.e., when the limbs are crossed, participants make mistakes and respond slowly
despite the fact that the task does not require participants to take posture or spatial aspects into account
in their decisions.
For details see the publication under https://doi.org/10.1101/2024.02.01.578364.
}
\keyword{datasets}
