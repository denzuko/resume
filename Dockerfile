FROM truepolyglot:latest AS build
ARG OUTPUT=resume.pdf
ENV OUTPUT $OUTPUT
WORKDIR /src
COPY cv.pdf /src/
COPY *.jar /src/
RUN truepolyglot szippdf --pdffile /src/cv.pdf --zipfile /src/*.jar --acrobat-compatibility $OUTPUT

FROM scratch AS assets
COPY --from=build /src/resume.pdf /
