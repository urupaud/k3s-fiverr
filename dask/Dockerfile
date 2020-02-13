FROM daskdev/dask-notebook

USER root

COPY --chown=1000:100 test_code/ /home/$NB_USER/test_code

USER $NB_USER

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]

CMD ["start.sh", "jupyter", "lab"]
